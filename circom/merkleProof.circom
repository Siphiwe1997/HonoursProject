pragma circom 2.0.0;

include "node_modules/circomlib/circuits/poseidon.circom";
include "node_modules/circomlib/circuits/mux2.circom"; 
include "node_modules/circomlib/circuits/comparators.circom"; 

template MerkleProof(depth) {
    signal input leaf;
    signal input root;
    signal input pathElements[depth];
    signal input pathIndices[depth]; // 0 or 1, indicating the side of the path

    signal output isValid;

    signal tempHash[depth + 1];  // Array to hold temp hashes at each level
    tempHash[0] <== leaf;        // Initialize with the leaf value

    component hasher[depth];
    component leftSelector[depth];  // Mux2 for left input selection
    component rightSelector[depth]; // Mux2 for right input selection

    for (var i = 0; i < depth; i++) {
        hasher[i] = Poseidon(2);

        // Select left and right inputs based on pathIndices[i]
        leftSelector[i] = Mux2();
        rightSelector[i] = Mux2();

        // Initialize the four constants for each Mux2 component
        leftSelector[i].c[0] <== tempHash[i];        // Left input
        leftSelector[i].c[1] <== pathElements[i];    // Right input
        leftSelector[i].c[2] <== 0;                  // Unused constant
        leftSelector[i].c[3] <== 0;                  // Unused constant
        leftSelector[i].s[0] <== pathIndices[i];     // Single selector bit
        leftSelector[i].s[1] <== 0;                  // Unused selector bit

        rightSelector[i].c[0] <== pathElements[i];   // Left input
        rightSelector[i].c[1] <== tempHash[i];       // Right input
        rightSelector[i].c[2] <== 0;                 // Unused constant
        rightSelector[i].c[3] <== 0;                 // Unused constant
        rightSelector[i].s[0] <== pathIndices[i];    // Single selector bit
        rightSelector[i].s[1] <== 0;                 // Unused selector bit

        // Use the output of the mux as the input to the Poseidon hash
        hasher[i].inputs[0] <== leftSelector[i].out;  // Select left input
        hasher[i].inputs[1] <== rightSelector[i].out; // Select right input

        tempHash[i + 1] <== hasher[i].out;  // Update tempHash for the next level
    }

    // The root is the final hash
    signal diff;
    diff <== tempHash[depth] - root;

    // Use IsEqual to check if diff == 0
    component isEqual = IsEqual();
    isEqual.in[0] <== diff;
    isEqual.in[1] <== 0;

    // Set isValid based on whether diff == 0
    isValid <== isEqual.out;
}
