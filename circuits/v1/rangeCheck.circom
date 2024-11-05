pragma circom 2.0.0;

template RangeCheck(n) {
    signal input values[n];
    signal input minVal;
    signal input maxVal;
    signal output withinRange;

    signal inRange[n];
    signal cumulativeRange[n];
    signal diffLow[n], diffHigh[n];

    // Declare component arrays for isPositiveLow and isPositiveHigh
    component isPositiveLow[n];
    component isPositiveHigh[n];

    // For each value, we need to check if it is within the range [minVal, maxVal]
    for (var i = 0; i < n; i++) {
        diffLow[i] <== values[i] - minVal;
        diffHigh[i] <== maxVal - values[i];

        // Instantiate IsNonNegative component for each value in the array
        isPositiveLow[i] = IsNonNegative();
        isPositiveLow[i].in <== diffLow[i];

        isPositiveHigh[i] = IsNonNegative();
        isPositiveHigh[i].in <== diffHigh[i];

        // Both conditions must be true for the value to be in range
        inRange[i] <== isPositiveLow[i].out * isPositiveHigh[i].out;

        if (i == 0) {
            cumulativeRange[i] <== inRange[i];
        } else {
            cumulativeRange[i] <== cumulativeRange[i - 1] * inRange[i];
        }
    }

    withinRange <== cumulativeRange[n - 1];  // 1 if all values are in range, 0 otherwise
}

template IsNonNegative() {
    signal input in;

    signal output out;

    // Decompose the signal into bits to check non-negativity
    signal bits[256];

    // Decompose the signal into binary representation
    component rangeCheck = Num2Bits(256);
    rangeCheck.in <== in;

    // Check if all higher-order bits are zero, ensuring the number is non-negative
    out <== 1 - rangeCheck.out[255]; // Check the sign bit (255th bit)
}
