pragma circom 2.1.6;

include "rlwe_keygen.circom";
include "rlwe_encrypt.circom";
include "rlwe_decrypt.circom";
include "merkleTree.circom"; 
include "merkleTreeProof.circom";

template RLWEMain(polyOrder, numPolys, depth, primeMod, roots, invRoots) {
    //==========Inputs==========
    signal input scalar;      
    signal input base[numPolys][polyOrder];
    signal input leaves_ct1[2**depth][numPolys][polyOrder];
    signal input leaves_ct2[2**depth][numPolys][polyOrder];
    signal input sk[numPolys][polyOrder];          // Secret key as a 2D array
    signal input publicPoly[numPolys][polyOrder];  // Public polynomials a(x)
    signal input noise[numPolys][polyOrder];       // Noise polynomials e(x)
    signal input rand[numPolys][polyOrder];        // Random polynomials r(x)
    //signal input unique_randPoly[2**depth][numPolys][polyOrder];

    //========Outputs===========
    signal output product[numPolys][polyOrder];
    signal output public_key_c[numPolys][polyOrder];
    signal output roots_sum [numPolys][polyOrder];
    signal output ciphertext_sum[numPolys][polyOrder];
    signal output decrypted_message[numPolys][polyOrder];
    
    
    //===========SIGNALS==========
    signal public_key_a[numPolys][polyOrder];
    signal public_key_b[numPolys][polyOrder];
    signal ciphertext1[numPolys][polyOrder];
    signal ciphertext2[numPolys][polyOrder];
    signal pathElements_ct1[depth][2**depth][numPolys][polyOrder];  // Path elements (ct1)
    signal pathElements_ct2[depth][2**depth][numPolys][polyOrder];  // Path elements (ct2)
    signal root_ct1[numPolys][polyOrder];  // Merkle tree root (ciphertext 1)
    signal root_ct2[numPolys][polyOrder];  // Merkle tree root (ciphertext 2)
    signal pathElements_sum [depth][2**depth][numPolys][polyOrder];


    //====SCALAR MULTIPLICATION USING NTT======
    component nttMul[numPolys][polyOrder];
    signal tempProduct[numPolys][polyOrder]; 
    for (var p = 0; p < numPolys; p++) {
        for (var i = 0; i < polyOrder; i++) {
            nttMul[p][i] = NTT(polyOrder, primeMod, roots);
            for (var j = 0; j < polyOrder; j++) {
                nttMul[p][i].inputs[j] <== scalar + noise[p][i];
            }
            tempProduct[p][i] <== nttMul[p][i].results[0] * base[p][i];  // Multiply first result by base
        }
        for (var i = 0; i < polyOrder; i++) {
            product[p][i] <== tempProduct[p][i];  // Assign the final result to product
        }
    }

    //==========RLWE KEY GENERATION============
    component keygen = RLWEKeyGen(polyOrder, numPolys, primeMod, roots);
    for (var p = 0; p < numPolys; p++) {
        for (var i = 0; i < polyOrder; i++) {
            keygen.publicPoly[p][i] <== publicPoly[p][i];
            keygen.sk[p][i] <== sk[p][i];
            keygen.noisePoly[p][i] <== noise[p][i];
        }
    }

    // Assign public keys from key generation to public_key_a and public_key_b
    for (var p = 0; p < numPolys; p++) {
        for (var i = 0; i < polyOrder; i++) {
            public_key_a[p][i] <== keygen.pk_a[p][i];
            public_key_b[p][i] <== keygen.pk_b[p][i];
        }
    }

    for (var p = 0; p < numPolys; p++) {
        for (var i = 0; i < polyOrder; i++) {
            public_key_c[p][i] <== public_key_a[p][i] + public_key_b[p][i];
        }
    }

    //==========RLWE ENCRYPTION===============
    component encrypt = RLWEEncrypt(polyOrder, numPolys, primeMod, roots);
    for (var p = 0; p < numPolys; p++) {
        for (var i = 0; i < polyOrder; i++) {
            encrypt.randPoly[p][i] <== rand[p][i];
            encrypt.pk_a[p][i] <== public_key_a[p][i];
            encrypt.pk_b[p][i] <== public_key_b[p][i];
            encrypt.msg[p][i] <== product[p][i];
        }
    }

    //===============OUTPUT======================
    for (var p = 0; p < numPolys; p++) {
        for (var i = 0; i < polyOrder; i++) {
            ciphertext1[p][i] <== encrypt.ct1[p][i];
            ciphertext2[p][i] <== encrypt.ct2[p][i];
        }
    }

    for (var p = 0; p < numPolys; p++) {
        for (var i = 0; i < polyOrder; i++) {
            ciphertext_sum[p][i] <== ciphertext1[p][i] + ciphertext2[p][i];
        }
    }

    //=============RLWE DECRYPTION===============
    component decrypt = RLWEDecrypt(polyOrder, numPolys, primeMod, invRoots);
    for (var p = 0; p < numPolys; p++) {
        for (var i = 0; i < polyOrder; i++) {
            decrypt.ct1[p][i] <== ciphertext1[p][i];
            decrypt.ct2[p][i] <== ciphertext2[p][i];
            decrypt.sk[p][i] <== sk[p][i];
        }
    }

    //===============OUTPUT======================
    for (var p = 0; p < numPolys; p++) {
        for (var i = 0; i < polyOrder; i++) {
            decrypted_message[p][i] <== decrypt.msg[p][i];
        }
    }

    // ============== MERKLE TREE INSTANCE ==============
    component merkleTree = MerkleTree(depth, polyOrder, numPolys, primeMod, roots);
    
   // Assign inputs to Merkle tree leaves
    for (var p = 0; p < numPolys; p++) {
        for (var i = 0; i < polyOrder; i++) {
            for (var d = 0; d < 2**depth; d++) {
                merkleTree.leaves_ct1[d][p][i] <== leaves_ct1[d][p][i];  // Assign leaves to ct1
                merkleTree.leaves_ct2[d][p][i] <== leaves_ct2[d][p][i];  // Assign leaves to ct2
            }
        }
    }
    
    //===============OUTPUT======================
    for (var p = 0; p < numPolys; p++) {
        for (var i = 0; i < polyOrder; i++) {
            root_ct1[p][i] <== merkleTree.root_ct1[p][i];  // Assign Merkle root for ct1
            root_ct2[p][i] <== merkleTree.root_ct2[p][i];  // Assign Merkle root for ct2
        }
    }
    
    // Path Elements Output
    for (var d = 0; d < depth; d++) {
        for (var leaf = 0; leaf < 2**depth; leaf++) {
            for (var p = 0; p < numPolys; p++) {
                for (var i = 0; i < polyOrder; i++) {
                    pathElements_ct1[d][leaf][p][i] <== merkleTree.pathElements_ct1[d][leaf][p][i];
                    pathElements_ct2[d][leaf][p][i] <== merkleTree.pathElements_ct2[d][leaf][p][i];
                }
            }
        }
    }

     // Path Elements output
    for (var d = 0; d < depth; d++) {
        for (var leaf = 0; leaf < 2**depth; leaf++) {
            for (var p = 0; p < numPolys; p++) {
                for (var i = 0; i < polyOrder; i++){
                    pathElements_sum[d][leaf][p][i] <== pathElements_ct1[d][leaf][p][i] + pathElements_ct1[d][leaf][p][i];
                }
            }
        }
    }
    for (var p = 0; p < numPolys; p++) {
        for (var i = 0; i < polyOrder; i++) {
            roots_sum[p][i] <== root_ct1[p][i] + root_ct2[p][i];
        }
    }
}

component main = RLWEMain(4, 4, 3, 122289, [1, 7, 49, 343], [1, 10553, 3921, 8654]);

