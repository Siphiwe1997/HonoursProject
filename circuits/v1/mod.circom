pragma circom 2.0.0;

include "msb.circom";
include "util.circom";
// based on: https://github.com/zkFHE/circomlib-fhe/blob/main/circuits/mod.circom

template Mod(q) {
    signal input in;  // Input value to reduce mod q
    signal output out;  // Output value reduced mod q

    signal quotient;
    signal remainder;

    // Perform division
    quotient <-- in \ q;
    remainder <-- in % q;

    // Ensure remainder is less than q
    component lt_q = LtConstant_q(q);  // Comparison template
    lt_q.in <== remainder;
    lt_q.out === 1;  // Ensure remainder is less than q

    // Constrain the relation: in = quotient * q + remainder
    in === quotient * q + remainder;

    // Output the remainder
    out <== remainder;
}

// return in % q, given that 0 <= in <= b
// assumes 1 < q <= 2^252, 0 <= b <= 2^252

template ModBound(q, b) {
    signal input in;
    signal quotient;
    signal remainder;
    signal output out;

    // Compute quotient and remainder
    quotient <-- in \ q;
    remainder <-- in % q;

    // Ensure remainder < q
    component lt_q = LtConstant(q);
    lt_q.in <== remainder;
    signal isLessThanQ;
    isLessThanQ <== lt_q.out;  // Constraint to ensure remainder < q
    out <== remainder;  // Assign the remainder to the output directly

    // Ensure quotient < (b // q) + 1
    var bound_quot = b \ q + 1;
    component lt_bound_quot = LtConstant(bound_quot);
    lt_bound_quot.in <== quotient;
    signal isLessThanBoundQuot;
    isLessThanBoundQuot <== lt_bound_quot.out;  // Constraint to ensure quotient < bound_quot

    // Final constraint: in = quotient * q + remainder
    in === quotient * q + remainder;
}
