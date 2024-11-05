pragma circom 2.1.6;

include "ntt.circom";
include "mod.circom";

template RLWEEncrypt(n, q, roots) {
    signal input pk_a[n];  // Public key polynomial a(x)
    signal input pk_b[n];  // Public key polynomial b(x)
    signal input msg[n];  // Message polynomial m(x)
    signal input randPoly[n];  // Random polynomial r(x)
    signal output ct1[n];  // Ciphertext component c1(x)
    signal output ct2[n];  // Ciphertext component c2(x)

    signal tempProduct1[n];  // Temporary storage for a(x) * r(x)
    signal tempProduct2[n];  // Temporary storage for b(x) * r(x)
    signal tempSum[n];  // Temporary storage for (b(x) * r(x)) + m(x)

    // Declare NTT component
    component nttRandPoly = NTT(n, q, roots);

    // Declare constant-time Mod(q) components
    component mod_ct1[n];
    component mod_ct2[n];
    for (var idx = 0; idx < n; idx++) {
        mod_ct1[idx] = Mod(q);
        mod_ct2[idx] = Mod(q);
    }

    // NTT of random polynomial r(x)
    for (var idx = 0; idx < n; idx++) {
        nttRandPoly.values[idx] <== randPoly[idx];
    }

    // Encryption:
    // ct1(x) = a(x) * r(x) mod q
    // ct2(x) = (b(x) * r(x)) + m(x) mod q
    for (var idx = 0; idx < n; idx++) {
        // Compute a(x) * r(x) mod q for ciphertext1
        tempProduct1[idx] <== pk_a[idx] * nttRandPoly.out[idx];  // Constant-time multiplication
        mod_ct1[idx].in <== tempProduct1[idx];
        ct1[idx] <== mod_ct1[idx].out;

        // Compute b(x) * r(x) mod q, then add message for ciphertext2
        tempProduct2[idx] <== pk_b[idx] * nttRandPoly.out[idx];  // Constant-time multiplication
        tempSum[idx] <== tempProduct2[idx] + msg[idx];  // Constant-time addition

        // Modular reduction for ciphertext2
        mod_ct2[idx].in <== tempSum[idx];
        ct2[idx] <== mod_ct2[idx].out;
    }
}
