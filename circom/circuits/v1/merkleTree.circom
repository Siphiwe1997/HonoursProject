pragma circom 2.0.0;

include "node_modules/circomlib/circuits/poseidon.circom";


template MerkleTree(depth) {
    signal input leaves[2**depth];         // Input leaves for the tree
    signal output root;                    // Merkle tree root
    signal output pathElements[depth][2**depth]; // Outputs intermediate nodes for proof

    // 2D array for storing the intermediate hash values at each level
    signal hashLevels[depth + 1][2**depth];

    // Initialize the first level (the leaves)
    for (var i = 0; i < 2**depth; i++) {
        hashLevels[0][i] <== leaves[i];
    }
        
    // Calculate hashes for each subsequent level
    component hasher[depth][2**(depth-1)];
    for (var i = 0; i < depth; i++) {
        for (var j = 0; j < 2**(depth-i-1); j++) {
            hasher[i][j] = Poseidon(2);
            hasher[i][j].inputs[0] <== hashLevels[i][2*j];       // Left child
            hasher[i][j].inputs[1] <== hashLevels[i][2*j + 1];   // Right child
            hashLevels[i+1][j] <== hasher[i][j].out;             // Store the result in the next level

            // Store the path element (needed for Merkle proof)
            pathElements[i][2*j] <== hashLevels[i][2*j];         // Left child for proof
            pathElements[i][2*j+1] <== hashLevels[i][2*j + 1];   // Right child for proof
        }

    }

    // The root is the final hash at the top level
    root <== hashLevels[depth][0];
}


