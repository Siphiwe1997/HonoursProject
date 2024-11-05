import { randomInt, random, sqrt, log, pi, cos, sin } from "mathjs";

class RLWE {
  constructor(n = 1024, q = 12289, sigma = 2.0) {
    this.n = n; // Degree of the polynomial ring
    this.q = q; // Large prime modulus
    this.sigma = sigma; // Standard deviation for noise
    this.secretKey = this.#sampleBinary(); // Secret key (random binary vector)
  }

  // Encrypt a message (binary array)
  encrypt(message, publicKey) {
    const { a, b } = publicKey;
    const r = this.#sampleBinary(); // Random binary vector 'r'

    // Encrypt message: c1 = a * r mod q, c2 = b * r + m * (q/2) mod q
    const c1 = this.#multiplyPoly(a, r); // c1 = a * r mod q
    const encodedMessage = this.#encodeMessage(message); // Encode message to mod q form
    const c2 = this.#addPoly(this.#multiplyPoly(b, r), encodedMessage); // c2 = b * r + m * (q/2) mod q

    return { c1, c2 }; // Return ciphertext (c1, c2)
  }

  // Decrypt ciphertext to retrieve message
  decrypt(c1, c2) {
    const decrypted = this.#addPoly(c2, this.#negatePoly(this.#multiplyPoly(c1, this.secretKey))); // c2 - c1 * s mod q
    return this.#decodeMessage(decrypted); // Decode to original binary message
  }

  // Generate random binary vector (secret key)
  #sampleBinary() {
    return Array.from({ length: this.n }, () => randomInt(0, 2));
  }

  // Gaussian sampling using Box-Muller Transform
  #sampleGaussian() {
    const samples = [];
    for (let i = 0; i < this.n; i += 2) {
      const u1 = random();
      const u2 = random();
      const z0 = sqrt(-2.0 * log(u1)) * cos(2 * pi * u2);
      const z1 = sqrt(-2.0 * log(u1)) * sin(2 * pi * u2);
      samples.push(Math.round(z0 * this.sigma), Math.round(z1 * this.sigma));
    }
    return samples.slice(0, this.n); // Return only `n` samples
  }

  // Key generation function
  keygen() {
    const a = this.#sampleUniform(); // Public key component 'a'
    const e = this.#sampleGaussian(); // Gaussian error 'e'
    const b = this.#addPoly(this.#multiplyPoly(a, this.secretKey), e); // b = a * s + e mod q
    return { a, b }; // Return public key (a, b)
  }

  // Uniform sampling in range [0, q)
  #sampleUniform() {
    return Array.from({ length: this.n }, () => randomInt(0, this.q));
  }

  // Add two polynomials (component-wise addition mod q)
  #addPoly(poly1, poly2) {
    return poly1.map((val, i) => (val + poly2[i]) % this.q);
  }

  // Multiply two polynomials (component-wise multiplication mod q)
  #multiplyPoly(poly1, poly2) {
    return poly1.map((val, i) => (val * poly2[i]) % this.q);
  }

  // Encode binary message as polynomial mod q (m * q/2 for each bit)
  #encodeMessage(message) {
    const halfQ = Math.floor(this.q / 2);
    return Array.from({ length: this.n }, (_, i) => message[i % message.length] * halfQ);
  }

  // Negate polynomial (modular negation)
  #negatePoly(poly) {
    return poly.map((val) => (-val + this.q) % this.q);
  }

  // Decode polynomial to binary message (based on proximity to q/2)
  #decodeMessage(decrypted) {
    const halfQ = Math.floor(this.q / 2);
    return decrypted.map((val) => (val > halfQ ? 1 : 0)); // If > q/2, it is 1; otherwise, 0
  }
}

export default RLWE;
