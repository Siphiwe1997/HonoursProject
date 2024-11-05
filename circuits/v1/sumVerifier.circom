pragma circom 2.0.0;

template SumVerifier(n) {
    signal input a[n];
    signal input b[n];
    signal input sum[n];
    signal output isValid;

    signal tempIsValid[n];
    signal cumulativeValid[n];
    signal diff[n];

    for (var i = 0; i < n; i++) {
        diff[i] <== sum[i] - a[i] - b[i];
        tempIsValid[i] <== 1 - diff[i] * diff[i];

        if (i == 0) {
            cumulativeValid[i] <== tempIsValid[i];
        } else {
            cumulativeValid[i] <== cumulativeValid[i - 1] * tempIsValid[i];
        }
    }

    isValid <== cumulativeValid[n - 1];
}

