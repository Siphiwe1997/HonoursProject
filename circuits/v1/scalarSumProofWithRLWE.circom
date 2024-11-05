pragma circom 2.0.0;

include "node_modules/circomlib/circuits/poseidon.circom";
include "merkleTree.circom";
include "merkleProof.circom";
include "rlwe_keygen.circom";
include "rlwe_encrypt.circom";
include "rlwe_decrypt.circom";
include "sumVerifier.circom";
include "rangeCheck.circom";
include "commitmentProof.circom";
include "ntt.circom";         // NTT for modular arithmetic and polynomial operations
include "invntt.circom";
include "mod.circom";         // Modular reduction templates

template ScalarSumProofWithRLWE(n, depth, selectedLeafIndex, q, roots, invRoots) {
    // Inputs
    signal input scalar;      
    signal input base[n];       
    signal input leaf;                  // Input leaf for Merkle Proof verification
    signal input pathIndices[depth];    // Path indices (0 or 1 for left or right)
    signal input commitments[n];
    signal input leaves[2**depth]; 
    signal input publicPoly[n];        // Public polynomials a(x)
    signal input rand[n];              // Random polynomials r(x)
    signal input secretKey[n];         // Secret key for RLWE encryption
    signal input gaussianNoise[n];     // Noise polynomials e(x)

    // Outputs
    signal output isValidMerkle;       // Output for Merkle proof validation  
    signal output isValidSum;          
    signal output hashedSumsInRange;
    signal output isValidCommitment;
    signal output root;                // Merkle tree root
    signal output product[n];
    signal output hashedSums[n];    
    signal output ciphertext1[n];
    signal output ciphertext2[n];
    signal output decrypted_plaintext[n];
    signal output encryptedSum[n];
    signal output decryptedSum[n];
    
    signal pathElements[depth];         // Path elements (to be initialized)
    signal public_key_a[n];
    signal public_key_b[n];

    // Scalar multiplication as polynomial multiplication using NTT
    component nttMul[n];
    signal tempProduct[n][n]; 
    for (var i = 0; i < n; i++) {
        nttMul[i] = NTT(n, q, roots);
        for (var j = 0; j < n; j++) {
            nttMul[i].values[j] <== scalar;  // Scalar as a polynomial with repeated coefficients
        }
        // Perform NTT-based multiplication (polynomial multiplication in ring)
        for (var j = 0; j < n; j++) {
            tempProduct[i][j] <== nttMul[i].out[j];  // Store result in tempProduct array
        }
        product[i] <== tempProduct[i][0] * base[i];
    }
    
    //==========RLWE KEY GENERATION============
    component keygen = RLWEKeyGen(n, q, roots);
    for (var i = 0; i < n; i++) {
        keygen.publicPoly[i] <== publicPoly[i];
        keygen.sk[i] <== secretKey[i];
        keygen.noisePoly[i] <== gaussianNoise[i];
    }

    for (var i = 0; i < n; i++) {
        public_key_a[i] <== keygen.pk_a[i];
        public_key_b[i] <== keygen.pk_b[i];
    }

    // Instantiate RLWE Encryption component
    component encrypt = RLWEEncrypt(n, q, roots);
    for (var i = 0; i < n; i++) {
        encrypt.randPoly[i] <== rand[i];
        encrypt.pk_a[i] <== public_key_a[i];
        encrypt.pk_b[i] <== public_key_b[i];
        encrypt.msg[i] <== product[i];
    }

    //===============OUTPUT======================
    for (var i = 0; i < n; i++) {
        ciphertext1[i] <== encrypt.ct1[i];
        ciphertext2[i] <== encrypt.ct2[i];
    }

    //=============RLWE DECRYPTION===============
    component decrypt = RLWEDecrypt(n, q, invRoots);
    for (var i = 0; i < n; i++) {
        decrypt.ct1[i] <== ciphertext1[i];
        decrypt.ct2[i] <== ciphertext2[i];
        decrypt.sk[i] <== secretKey[i];
    }
    //===============OUTPUT======================
    for (var i = 0; i < n; i++) {
        decrypted_plaintext[i] <== decrypt.msg[i];
    }


    // Poseidon hash for ciphertext1 and ciphertext2
    component poseidonHasher[n];
    for (var i = 0; i < n; i++) {
        poseidonHasher[i] = Poseidon(2);
        poseidonHasher[i].inputs[0] <== ciphertext1[i]; // First input to Poseidon
        poseidonHasher[i].inputs[1] <== ciphertext2[i]; // Second input to Poseidon
        hashedSums[i] <== poseidonHasher[i].out; // Store Poseidon output in hashedSums
    }
    
    for(var i = 0; i < n; i++){
        encryptedSum[i] <== ciphertext1[i] + ciphertext2[i];
    }
      
    // Sum verification using RLWE-encrypted values
    component sumVerifier = SumVerifier(n);
    for (var i = 0; i < n; i++) {
        sumVerifier.a[i] <== ciphertext1[i];
        sumVerifier.b[i] <== ciphertext2[i];
        sumVerifier.sum[i] <== encryptedSum[i];
    }
    isValidSum <== sumVerifier.isValid;

    // Instantiate the MerkleTree component
    component merkleTree = MerkleTree(depth);

    // Connect the inputs for the Merkle Tree
    for (var i = 0; i < 2**depth; i++) {
        merkleTree.leaves[i] <== leaves[i];
    }

    // The root of the Merkle Tree
    root <== merkleTree.root;

    // Calculate path elements explicitly
    for (var i = 0; i < depth; i++) {
        if (selectedLeafIndex % 2 == 0) {
            // If the selected leaf index is even, sibling is at index selectedLeafIndex + 1
            pathElements[i] <== merkleTree.pathElements[i][selectedLeafIndex + 1];
        } else {
            // If the selected leaf index is odd, sibling is at index selectedLeafIndex - 1
            pathElements[i] <== merkleTree.pathElements[i][selectedLeafIndex - 1];
        }
    }

    // Instantiate the MerkleProof component
    component merkleProof = MerkleProof(depth);

    // Connect the inputs for the Merkle Proof
    merkleProof.leaf <== leaf;                   // The selected leaf (from input)
    merkleProof.root <== root;                   // The root from the Merkle tree
    for (var i = 0; i < depth; i++) {
        merkleProof.pathElements[i] <== pathElements[i];  // Path elements from the MerkleTree
        merkleProof.pathIndices[i] <== pathIndices[i];    // Path indices from input
    }

    // Output the validity of the proof
    isValidMerkle <== merkleProof.isValid;

    for(var i = 0; i < n; i++){
        decryptedSum[i] <== ciphertext1[i] + ciphertext2[i];  // Combine ciphertexts for decryption
    }

    // Range check for hashed sums
    component rangeCheckHashed = RangeCheck(n);
    rangeCheckHashed.minVal <== 0;
    rangeCheckHashed.maxVal <== 2**253 - 1;
    for (var i = 0; i < n; i++) {
        rangeCheckHashed.values[i] <== hashedSums[i];
    }
    
    hashedSumsInRange <== rangeCheckHashed.withinRange;

    // Zero-knowledge commitments
    component zkCommitment = CommitmentProof(n);
    for (var i = 0; i < n; i++) {
        zkCommitment.inputs[i] <== product[i]; // Committing product
        zkCommitment.commitments[i] <== commitments[i] ; // Commitment is the Poseidon hash
    }
    isValidCommitment <== zkCommitment.isValid;
}

component main = ScalarSumProofWithRLWE(4, 3, 0, 12228,[1, 7, 49, 343], [1, 10553, 3921, 8654]);
