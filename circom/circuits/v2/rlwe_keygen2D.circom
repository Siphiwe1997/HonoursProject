pragma circom 2.1.6;

include "ntt.circom";
include "mod.circom";

template RLWEKeyGen(polyOrder, numPolys, primeMod, rootValues) {
    signal input sk[numPolys][polyOrder];  // Secret key polynomials s(x) for each dimension
    signal input publicPoly[numPolys][polyOrder];  // Public polynomials a(x) for each dimension
    signal input noisePoly[numPolys][polyOrder];  // Noise polynomials e(x) for each dimension
    signal output pk_a[numPolys][polyOrder];  // Public keys a(x) for each dimension
    signal output pk_b[numPolys][polyOrder];  // Public keys b(x) for each dimension

    signal tempProduct[numPolys][polyOrder];  // Temporary storage for product in each dimension
    signal tempSum[numPolys][polyOrder];  // Temporary storage for sum in each dimension

    // Declare NTT component outside the loop and reuse it
    component nttPublicPoly[numPolys];
    for (var p = 0; p < numPolys; p++) {
        nttPublicPoly[p] = NTT(polyOrder, primeMod, rootValues);
    }

    // Declare constant-time Mod(primeMod) components outside the loop and reuse them
    component mod_pkA[numPolys][polyOrder];
    component mod_pkB[numPolys][polyOrder];
    for (var p = 0; p < numPolys; p++) {
        for (var idx = 0; idx < polyOrder; idx++) {
            mod_pkA[p][idx] = Mod(primeMod);
            mod_pkB[p][idx] = Mod(primeMod);
        }
    }

    // Loop over each polynomial dimension (numPolys)
    for (var p = 0; p < numPolys; p++) {
        // NTT of public polynomial a(x) in the current dimension
        for (var idx = 0; idx < polyOrder; idx++) {
            nttPublicPoly[p].inputs[idx] <== publicPoly[p][idx];
        }

        // Public key generation: b(x) = (a(x) * s(x)) + e(x), all mod primeMod
        for (var idx = 0; idx < polyOrder; idx++) {
            // Modulo reduction for public key a(x) in NTT form
            mod_pkA[p][idx].in <== nttPublicPoly[p].results[idx];
            pk_a[p][idx] <== mod_pkA[p][idx].out;  // a(x) stays in NTT form and reduced mod primeMod

            // Perform multiplication mod primeMod and then add the noise
            tempProduct[p][idx] <== nttPublicPoly[p].results[idx] * sk[p][idx];  // Constant-time multiplication
            tempSum[p][idx] <== tempProduct[p][idx] + noisePoly[p][idx];

            // Modular reduction for public key b(x)
            mod_pkB[p][idx].in <== tempSum[p][idx];
            pk_b[p][idx] <== mod_pkB[p][idx].out;  // Output public key b(x) reduced mod primeMod
        }
    }
}
