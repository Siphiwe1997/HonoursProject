pragma circom 2.0.0;

function min(x, y) {
    if (x > y) {
        return y;
    } else {
        return x;
    }
}

function max(x, y) {
    if (x > y) {
        return x;
    } else {
        return y;
    }
}

function add(x, y) {
    return x + y;
}

function sub(q, x, y) {
    return x + q - y;
}

function guard(x) {
    return x;
}

function mul_root(x, r) {
    return x * r;
}

function size_add(s1, s2) {
    return max(s1, s2) + 1;
}

function size_mul(s1, s2) {
    return s1 + s2;
}


// assumes 0 <= a <= 2^252
function log2(a) {
    return logb(a, 2);
}

// assumes 0 <= a <= b^k where k is the largest integer such that b^k < p/2,
// where p is circom's prime
function logb(a, b) {
    if (a==0) {
        return 0;
    }
    var n = 1;
    var r = 0;
    while (n<a) {
        r++;
        n *= b;
    }
    return r;
}

function extended_gcd(a, b) {
    var old_r = a; 	var r = b;
    var old_s = 1; 	var s = 0;
    var old_t = 0; 	var t = 1;
    var quotient;
    
    while (r != 0) {
        quotient = old_r \ r;
        old_r = r; r = old_r - quotient * r;
        old_s = s; s = old_s - quotient * s;
        old_t = t; t = old_t - quotient * t;
    }
    
    return [old_s, old_t]; // old_s * a + old_t * b == 1
}
