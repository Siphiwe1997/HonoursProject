pragma circom 2.1.6;

include "ntt.circom";
include "mod.circom";

template RLWEDecrypt(polyOrder, numPolys, primeMod, invRootVals) {
    signal input sk[numPolys][polyOrder];    // Secret key polynomials s(x) for each dimension
    signal input ct1[numPolys][polyOrder];   // Ciphertext components c1(x) in NTT form for each dimension
    signal input ct2[numPolys][polyOrder];   // Ciphertext components c2(x) in NTT form for each dimension
    signal output msg[numPolys][polyOrder];  // Decrypted message polynomials m(x) for each dimension

    signal tempProduct[numPolys][polyOrder];   // Temporary storage for c1(x) * s(x) for each dimension
    signal tempDiff[numPolys][polyOrder];      // Temporary storage for (c2(x) - c1(x) * s(x)) for each dimension

    // Declare Inverse NTT (iNTT) components for each polynomial set (numPolys)
    component intt_ct1[numPolys];
    component intt_ct2[numPolys];
    for (var p = 0; p < numPolys; p++) {
        intt_ct1[p] = INTT(polyOrder, primeMod, invRootVals);  // Inverse NTT for c1(x)
        intt_ct2[p] = INTT(polyOrder, primeMod, invRootVals);  // Inverse NTT for c2(x)
    }

    // Declare Mod components for each polynomial set
    component mod_msg[numPolys][polyOrder];
    for (var p = 0; p < numPolys; p++) {
        for (var idx = 0; idx < polyOrder; idx++) {
            mod_msg[p][idx] = Mod(primeMod);
        }
    }

    // Perform Inverse NTT and decryption for each polynomial set
    for (var p = 0; p < numPolys; p++) {
        // Perform Inverse NTT to recover polynomials in the time domain
        for (var idx = 0; idx < polyOrder; idx++) {
            intt_ct1[p].inputs[idx] <== ct1[p][idx];  // c1(x) in time domain
            intt_ct2[p].inputs[idx] <== ct2[p][idx];  // c2(x) in time domain
        }

        // Perform polynomial multiplication and subtraction in time domain
        for (var idx = 0; idx < polyOrder; idx++) {
            // Multiply c1(x) by the secret key s(x) (ensure constant-time multiplication)
            tempProduct[p][idx] <== intt_ct1[p].results[idx] * sk[p][idx];

            // Subtract the result from c2(x) (ensure constant-time subtraction)
            tempDiff[p][idx] <== intt_ct2[p].results[idx] - tempProduct[p][idx];

            // Modular reduction to ensure result stays within [0, primeMod-1]
            mod_msg[p][idx].in <== tempDiff[p][idx];
            msg[p][idx] <== mod_msg[p][idx].out;
        }
    }
}
