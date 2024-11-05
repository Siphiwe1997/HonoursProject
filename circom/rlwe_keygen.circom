pragma circom 2.1.6;

include "ntt.circom";
include "mod.circom";

template RLWEKeyGen(n, q, roots) {
    signal input sk[n];  // Secret key polynomial s(x)
    signal input publicPoly[n];  // Public polynomial a(x)
    signal input noisePoly[n];  // Noise polynomial e(x)
    signal output pk_a[n];  // Public key a(x)
    signal output pk_b[n];  // Public key b(x)

    signal tempProduct[n];  // Temporary storage for product
    signal tempSum[n];  // Temporary storage for sum

    // Declare NTT component
    component nttPublicPoly = NTT(n, q, roots);

    // Declare constant-time Mod(q) components
    component mod_pkA[n];
    component mod_pkB[n];
    for (var idx = 0; idx < n; idx++) {
        mod_pkA[idx] = Mod(q);
        mod_pkB[idx] = Mod(q);
    }

    // NTT of public polynomial a(x)
    for (var idx = 0; idx < n; idx++) {
        nttPublicPoly.values[idx] <== publicPoly[idx];
    }

    // Public key generation: b(x) = (a(x) * s(x)) + e(x), all mod q
    for (var idx = 0; idx < n; idx++) {
        // Modulo reduction for public key a(x) in NTT form
        mod_pkA[idx].in <== nttPublicPoly.out[idx];
        pk_a[idx] <== mod_pkA[idx].out;  // a(x) stays in NTT form and reduced mod q

        // Perform multiplication mod q and then add the noise
        tempProduct[idx] <== nttPublicPoly.out[idx] * sk[idx];  // Constant-time multiplication
        tempSum[idx] <== tempProduct[idx] + noisePoly[idx];

        // Modular reduction for public key b(x)
        mod_pkB[idx].in <== tempSum[idx];
        pk_b[idx] <== mod_pkB[idx].out;  // Output public key b(x) reduced mod q
    }
}
