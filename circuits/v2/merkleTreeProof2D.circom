pragma circom 2.1.6;

include "circomlib/comparators.circom";
include "circomlib/mux2.circom";

template MerkleTreeProof(depth, polyOrder, numPolys, primeMod, rootVals) {
    signal input leaf_ct1[numPolys][polyOrder];    // Leaf to verify (ciphertext 1)
    signal input leaf_ct2[numPolys][polyOrder];    // Leaf to verify (ciphertext 2)
    signal input proofPath_ct1[depth][numPolys][polyOrder];  // Merkle proof path for ct1
    signal input proofPath_ct2[depth][numPolys][polyOrder];  // Merkle proof path for ct2
    signal input root_ct1[numPolys][polyOrder];    // Expected root (ciphertext 1)
    signal input root_ct2[numPolys][polyOrder];    // Expected root (ciphertext 2)
    signal input leafIndex;  // Leaf index in binary to know sibling ordering in each level

    // Initialize the first level of verification with the input leaf
    signal current_ct1[numPolys][polyOrder];
    signal current_ct2[numPolys][polyOrder];
    
    for (var p = 0; p < numPolys; p++) {
        for (var idx = 0; idx < polyOrder; idx++) {
            current_ct1[p][idx] <== leaf_ct1[p][idx];
            current_ct2[p][idx] <== leaf_ct2[p][idx];
        }
    }

    // Declare signals and components outside the loop
    signal isRightChild[depth];
    signal sel[depth];
    signal in0_ct1[depth][numPolys][polyOrder];
    signal in1_ct1[depth][numPolys][polyOrder];
    signal in0_ct2[depth][numPolys][polyOrder];
    signal in1_ct2[depth][numPolys][polyOrder];
    
    component mux_ct1[depth][numPolys][polyOrder];
    component mux_ct2[depth][numPolys][polyOrder];
    component rlweEncryptor[depth];  // Declare RLWEEncrypt components for each level

    for (var i = 0; i < depth; i++) {
        // Initialize RLWEEncryptor for each depth level
        rlweEncryptor[i] = RLWEEncrypt(polyOrder, numPolys, primeMod, rootVals);

        // Calculate isRightChild for this level
        isRightChild[i] <== (leafIndex >> i) & 1;
        sel[i] <== isRightChild[i];

        for (var p = 0; p < numPolys; p++) {
            for (var idx = 0; idx < polyOrder; idx++) {
                // Initialize Mux2 components
                mux_ct1[i][p][idx] = Mux2();
                mux_ct2[i][p][idx] = Mux2();

                // Connect selection and inputs for ct1
                mux_ct1[i][p][idx].sel <== sel[i];
                mux_ct1[i][p][idx].in0 <== current_ct1[p][idx];       // Left child (current)
                mux_ct1[i][p][idx].in1 <== proofPath_ct1[i][p][idx];  // Right child (proof path)
                rlweEncryptor[i].pk_a[p][idx] <== mux_ct1[i][p][idx].out;

                // Connect selection and inputs for ct2
                mux_ct2[i][p][idx].sel <== sel[i];
                mux_ct2[i][p][idx].in0 <== current_ct2[p][idx];       // Left child (current)
                mux_ct2[i][p][idx].in1 <== proofPath_ct2[i][p][idx];  // Right child (proof path)
                rlweEncryptor[i].pk_b[p][idx] <== mux_ct2[i][p][idx].out;

                rlweEncryptor[i].msg[p][idx] <== 0;
                rlweEncryptor[i].randPoly[p][idx] <== 1;
            }
        }

        // Update current node with encrypted result for the next level verification
        for (var p = 0; p < numPolys; p++) {
            for (var idx = 0; idx < polyOrder; idx++) {
                current_ct1[p][idx] <== rlweEncryptor[i].ct1[p][idx];
                current_ct2[p][idx] <== rlweEncryptor[i].ct2[p][idx];
            }
        }
    }

    // Final check against the given root
    for (var p = 0; p < numPolys; p++) {
        for (var idx = 0; idx < polyOrder; idx++) {
            root_ct1[p][idx] === current_ct1[p][idx];
            root_ct2[p][idx] === current_ct2[p][idx];
        }
    }
}
