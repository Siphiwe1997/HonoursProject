pragma circom 2.0.0;

template CommitmentProof(n) {
    signal input inputs[n];
    signal input commitments[n];
    signal output isValid;

    signal commitmentValid[n];

    for (var i = 0; i < n; i++) {
        commitmentValid[i] <== commitments[i] - inputs[i];
    }

    signal squaredCommitmentValid[n];
    signal validCommitment[n];

    for (var i = 0; i < n; i++) {
        squaredCommitmentValid[i] <== commitmentValid[i] * commitmentValid[i];
        validCommitment[i] <== 1 - squaredCommitmentValid[i];
    }

    signal cumulativeValid[n];

    for (var i = 0; i < n; i++) {
        if (i == 0) {
            cumulativeValid[i] <== validCommitment[i];
        } else {
            cumulativeValid[i] <== cumulativeValid[i - 1] * validCommitment[i];
        }
    }

    isValid <== cumulativeValid[n - 1];
}
