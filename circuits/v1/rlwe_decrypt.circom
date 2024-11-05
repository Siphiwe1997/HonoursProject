pragma circom 2.1.6;

include "invntt.circom";
include "mod.circom";

template RLWEDecrypt(n, q, invRoots) {
    signal input sk[n];    // Secret key polynomial s(x)
    signal input ct1[n];   // Ciphertext component c1(x) in NTT form
    signal input ct2[n];   // Ciphertext component c2(x) in NTT form
    signal output msg[n];  // Decrypted message polynomial m(x)

    signal tempProduct[n];   // Temporary storage for c1(x) * s(x)
    signal tempDiff[n];      // Temporary storage for (c2(x) - c1(x) * s(x))

    // Declare Inverse NTT (iNTT) components
    component intt_ct1 = InvNTT(n, q, invRoots);  // Inverse NTT for c1(x)
    component intt_ct2 = InvNTT(n, q, invRoots);  // Inverse NTT for c2(x)

    // Declare Mod components for each term in the polynomial
    component mod_msg[n];
    for (var idx = 0; idx < n; idx++) {
        mod_msg[idx] = Mod(q);
    }

    // Perform Inverse NTT to recover polynomials in the time domain
    for (var idx = 0; idx < n; idx++) {
        intt_ct1.values[idx] <== ct1[idx];  // c1(x) in time domain
        intt_ct2.values[idx] <== ct2[idx];  // c2(x) in time domain
    }

    // Perform polynomial multiplication and subtraction in time domain
    for (var idx = 0; idx < n; idx++) {
        // Multiply c1(x) by the secret key s(x)
        tempProduct[idx] <== intt_ct1.out[idx] * sk[idx];

        // Subtract the result from c2(x)
        tempDiff[idx] <== intt_ct2.out[idx] - tempProduct[idx];

        // Modular reduction to ensure result stays within [0, q-1]
        mod_msg[idx].in <== tempDiff[idx];
        msg[idx] <== mod_msg[idx].out;
    }
}
