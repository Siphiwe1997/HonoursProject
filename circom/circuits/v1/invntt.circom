pragma circom 2.0.0;

include "mod.circom";
include "util.circom";


// Define InvNTT template 
template InvNTT(n, q, inv_roots) {
    signal input values[n];
    var aux[n];
    var size[n];
    signal output out[n];

    // Initialize variables
    var r, u, v;
    var size_u, size_v;
    var gap = n >> 1;
    var size_q = log2(q);
    var inp_size = size_q;
    var size_r = size_q;
    var size_max = 332;

    // Copy input values to aux array
    for (var i = 0; i < n; i++) {
        aux[i] = values[i];
        size[i] = inp_size;
    }

    var root_idx = n >> 1;  // Start with the correct root index for INTT
    var x_idx, y_idx;

    // INTT main loop
    for (var m = 1; m < n; m <<= 1) {
        var offset = 0;
        for (var i = 0; i < m; i++) {
            r = inv_roots[root_idx];
            root_idx -= 1;
            x_idx = offset;
            y_idx = x_idx + gap;

            for (var j = 0; j < gap; j++) {
                u = aux[x_idx];
                size_u = size[x_idx];
                v = aux[y_idx];
                size_v = size[y_idx];

                aux[x_idx] = guard(add(u, v));
                size[x_idx] = size_add(size_u, size_v);

                if (size[x_idx] + 1 + size_r > size_max) {
                    aux[x_idx] = ModBound(q, (1 << size[x_idx]))(aux[x_idx]);
                    size[x_idx] = size_q;
                }

                aux[y_idx] = mul_root(sub(q, u, v), r);
                size[y_idx] = size_mul(size_add(size_u, size_v), size_r);

                if (size[y_idx] + 1 + size_r > size_max) {
                    aux[y_idx] = ModBound(q, (1 << size[y_idx]))(aux[y_idx]);
                    size[y_idx] = size_q;
                }

                x_idx++;
                y_idx++;
            }
            offset += gap << 1;
        }
        gap >>= 1;
    }

    // Output transformed values
    for (var i = 0; i < n; i++) {
        out[i] <== aux[i];
    }
}
