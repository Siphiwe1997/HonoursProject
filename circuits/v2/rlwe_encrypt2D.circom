pragma circom 2.1.6;

include "ntt.circom";
include "mod.circom";

template RLWEEncrypt(polyOrder, numPolys, primeMod, rootVals) {
    signal input pk_a[numPolys][polyOrder];  // Public key polynomials a(x) for each dimension
    signal input pk_b[numPolys][polyOrder];  // Public key polynomials b(x) for each dimension
    signal input msg[numPolys][polyOrder];  // Message polynomials m(x) for each dimension
    signal input randPoly[numPolys][polyOrder];  // Random polynomials r(x) for each dimension
    signal output ct1[numPolys][polyOrder];  // Ciphertext components c1(x) for each dimension
    signal output ct2[numPolys][polyOrder];  // Ciphertext components c2(x) for each dimension

    signal tempProduct1[numPolys][polyOrder];  // Temporary storage for a(x) * r(x) in each dimension
    signal tempProduct2[numPolys][polyOrder];  // Temporary storage for b(x) * r(x) in each dimension
    signal tempSum[numPolys][polyOrder];  // Temporary storage for (b(x) * r(x)) + m(x) in each dimension

    // Declare NTT component outside the loop for each dimension and reuse it
    component nttRandPoly[numPolys];
    for (var p = 0; p < numPolys; p++) {
        nttRandPoly[p] = NTT(polyOrder, primeMod, rootVals);
    }

    // Declare constant-time Mod(primeMod) components outside the loop for each dimension
    component mod_ct1[numPolys][polyOrder];
    component mod_ct2[numPolys][polyOrder];
    for (var p = 0; p < numPolys; p++) {
        for (var idx = 0; idx < polyOrder; idx++) {
            mod_ct1[p][idx] = Mod(primeMod);
            mod_ct2[p][idx] = Mod(primeMod);
        }
    }

    // Encryption:
    // ct1(x) = a(x) * r(x) mod primeMod
    // ct2(x) = (b(x) * r(x)) + m(x) mod primeMod
    for (var p = 0; p < numPolys; p++) {
        // NTT of random polynomial r(x) in each dimension
        for (var idx = 0; idx < polyOrder; idx++) {
            nttRandPoly[p].inputs[idx] <== randPoly[p][idx];
        }

        // Encrypt for each dimension
        for (var idx = 0; idx < polyOrder; idx++) {
            // Compute a(x) * r(x) mod primeMod for ciphertext1
            tempProduct1[p][idx] <== pk_a[p][idx] * nttRandPoly[p].results[idx];  // Constant-time multiplication
            mod_ct1[p][idx].in <== tempProduct1[p][idx];
            ct1[p][idx] <== mod_ct1[p][idx].out;

            // Compute b(x) * r(x) mod primeMod, then add message for ciphertext2
            tempProduct2[p][idx] <== pk_b[p][idx] * nttRandPoly[p].results[idx];  // Constant-time multiplication
            tempSum[p][idx] <== tempProduct2[p][idx] + msg[p][idx];  // Constant-time addition

            // Modular reduction for ciphertext2
            mod_ct2[p][idx].in <== tempSum[p][idx];
            ct2[p][idx] <== mod_ct2[p][idx].out;
        }
    }
}
