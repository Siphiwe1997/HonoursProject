pragma circom 2.1.6;  
include "ntt.circom";
include "mod.circom";
include "rlwe_encrypt.circom";

template MerkleTree(depth, polyOrder, numPolys, primeMod, rootVals) {
    signal input leaves_ct1[2**depth][numPolys][polyOrder];  // Input leaves for ciphertext 1
    signal input leaves_ct2[2**depth][numPolys][polyOrder];  // Input leaves for ciphertext 2
    signal output root_ct1[numPolys][polyOrder];  // Merkle tree root (ciphertext 1)
    signal output root_ct2[numPolys][polyOrder];  // Merkle tree root (ciphertext 2)
    signal output pathElements_ct1[depth][2**depth][numPolys][polyOrder];  // Path elements (ct1)
    signal output pathElements_ct2[depth][2**depth][numPolys][polyOrder];  // Path elements (ct2)

    // 2D array for storing the intermediate ciphertext values at each level
    signal ct1Levels[depth + 1][2**depth][numPolys][polyOrder];
    signal ct2Levels[depth + 1][2**depth][numPolys][polyOrder];

    // Initialize the first level (the leaves)
    for (var i = 0; i < 2**depth; i++) {
        for (var p = 0; p < numPolys; p++) {
            for (var idx = 0; idx < polyOrder; idx++) {
                ct1Levels[0][i][p][idx] <== leaves_ct1[i][p][idx];  // Assign input leaves for ct1
                ct2Levels[0][i][p][idx] <== leaves_ct2[i][p][idx];  // Assign input leaves for ct2
            }
        }
    }

    // RLWE encryption at each level of the Merkle tree
    component rlweEncryptors[depth][2**(depth-1)];
    for (var i = 0; i < depth; i++) {
        for (var j = 0; j < 2**(depth-i-1); j++) {
            rlweEncryptors[i][j] = RLWEEncrypt(polyOrder, numPolys, primeMod, rootVals);

            // Connect the polynomials of the left and right child as input to RLWE encryption
            for (var p = 0; p < numPolys; p++) {
                for (var idx = 0; idx < polyOrder; idx++) {
                    // Left and right child polynomials (from current level)
                    rlweEncryptors[i][j].pk_a[p][idx] <== ct1Levels[i][2*j][p][idx];  // Left child (ct1)
                    rlweEncryptors[i][j].pk_b[p][idx] <== ct1Levels[i][2*j + 1][p][idx];  // Right child (ct1)
                    rlweEncryptors[i][j].msg[p][idx] <== 0;  // Message is 0 for Merkle tree combination
                    rlweEncryptors[i][j].randPoly[p][idx] <== 1;  // Set random polynomial to 1 for simplicity
                }
            }

            // Store the encrypted result in the next level
            for (var p = 0; p < numPolys; p++) {
                for (var idx = 0; idx < polyOrder; idx++) {
                    ct1Levels[i+1][j][p][idx] <== rlweEncryptors[i][j].ct1[p][idx];  // Store ct1(x)
                    ct2Levels[i+1][j][p][idx] <== rlweEncryptors[i][j].ct2[p][idx];  // Store ct2(x)
                }
            }

            // Store the path elements for Merkle proof
            for (var p = 0; p < numPolys; p++) {
                for (var idx = 0; idx < polyOrder; idx++) {
                    pathElements_ct1[i][2*j][p][idx] <== ct1Levels[i][2*j][p][idx];  // Left child (ct1)
                    pathElements_ct1[i][2*j+1][p][idx] <== ct1Levels[i][2*j + 1][p][idx];  // Right child (ct1)
                    pathElements_ct2[i][2*j][p][idx] <== ct2Levels[i][2*j][p][idx];  // Left child (ct2)
                    pathElements_ct2[i][2*j+1][p][idx] <== ct2Levels[i][2*j + 1][p][idx];  // Right child (ct2)
                }
            }
        }
    }

    // The root is the final encrypted ciphertext at the top level
    for (var p = 0; p < numPolys; p++) {
        for (var idx = 0; idx < polyOrder; idx++) {
            root_ct1[p][idx] <== ct1Levels[depth][0][p][idx];  // Root of ciphertext 1
            root_ct2[p][idx] <== ct2Levels[depth][0][p][idx];  // Root of ciphertext 2
        }
    }
}

