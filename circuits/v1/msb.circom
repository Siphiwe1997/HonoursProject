pragma circom 2.0.0;
include "util.circom";

template GetMostSignificantBit(n) {
    signal input in;
    signal {binary} bits[n];
    signal output {binary} out;

    var lc1=0;

    var e2=1;
    for (var i = 0; i<n; i++) {
        bits[i] <-- (in >> i) & 1;
        bits[i] * (bits[i] - 1) === 0;
        lc1 += bits[i] * e2;
        e2 = e2+e2;
    }

    lc1 === in;
    out <== bits[n-1];
}

template LtConstant(ct) {
    signal input in;
    var n = log2(ct);

    component bit = GetMostSignificantBit(n+1);
    bit.in <== in + (1 << n) - ct;
    bit.out === 1;  
    signal output out <== 1 - bit.out;
}

template LtConstant_q(q) {
    signal input in;
    signal output out;

    // Get the bit length of q (number of bits needed to represent q)
    var n = log2(q) + 1;
    component msb = GetMostSignificantBit(n);
    msb.in <== in;
    // If the most significant bit of `in` is 0, `in < q`
    out <== 1 - msb.out;
}
