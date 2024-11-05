pragma circom 2.0.0;

include "mod.circom";
include "util.circom";   

template NTT(order, primeMod, rootList) {
    signal input inputs[order];
    var tempArr[order];
    var bitSize[order];
    signal output results[order];

    // Initialize variables
    var rootElement, upper, lower;
    var upperSize, lowerSize;
    var stride = 1;
    var primeSize = log2(primeMod);
    var inputSize = primeSize;
    var rootSize = primeSize;
    var maxBitSize = 252;

    for (var idx = 0; idx < order; idx++) {
        tempArr[idx] = inputs[idx];
        bitSize[idx] = inputSize;
    }

    var rootIndex = 0;
    var idxX, idxY;

    for (var mid = order >> 1; mid > 1; mid >>= 1) {
        var shift = 0;
        for (var loopIdx = 0; loopIdx < mid; loopIdx++) {
            rootIndex += 1;
            rootElement = rootList[rootIndex];
            idxX = shift;
            idxY = idxX + stride;

            for (var innerLoop = 0; innerLoop < stride; innerLoop++) {
                upper = tempArr[idxX];
                upperSize = bitSize[idxX];
                lower = tempArr[idxY];
                lowerSize = bitSize[idxY];

                tempArr[idxX] = guard(add(upper, lower));
                bitSize[idxX] = size_add(upperSize, lowerSize);

                if (bitSize[idxX] + 1 + rootSize > maxBitSize) {
                    tempArr[idxX] = ModBound(primeMod, (1 << bitSize[idxX]))(tempArr[idxX]);
                    bitSize[idxX] = primeSize;
                }

                tempArr[idxY] = mul_root(sub(primeMod, upper, lower), rootElement);
                bitSize[idxY] = size_mul(size_add(upperSize, lowerSize), rootSize);

                if (bitSize[idxY] + 1 + rootSize > maxBitSize) {
                    tempArr[idxY] = ModBound(primeMod, (1 << bitSize[idxY]))(tempArr[idxY]);
                    bitSize[idxY] = primeSize;
                }

                idxX++;
                idxY++;
            }
            shift += stride << 1;
        }
        stride <<= 1;
    }

    rootIndex += 1;
    idxX = 0;
    idxY = idxX + stride;

    for (var finalLoop = 0; finalLoop < stride; finalLoop++) {
        upper = tempArr[idxX];
        upperSize = bitSize[idxX];
        lower = tempArr[idxY];
        lowerSize = bitSize[idxY];

        tempArr[idxX] = guard(add(upper, lower));
        bitSize[idxX] = size_add(upperSize, lowerSize);

        if (bitSize[idxX] + 1 + rootSize > maxBitSize) {
            tempArr[idxX] = ModBound(primeMod, (1 << bitSize[idxX]))(tempArr[idxX]);
            bitSize[idxX] = primeSize;
        }

        tempArr[idxY] = mul_root(sub(primeMod, upper, lower), rootElement);
        bitSize[idxY] = size_mul(size_add(upperSize, lowerSize), rootSize);

        if (bitSize[idxY] + 1 + rootSize > maxBitSize) {
            tempArr[idxY] = ModBound(primeMod, (1 << bitSize[idxY]))(tempArr[idxY]);
            bitSize[idxY] = primeSize;
        }
    }

    for (var idx = 0; idx < order; idx++) {
        results[idx] <== tempArr[idx];
    }
}

template INTT(order, primeMod, rootList) {
    signal input inputs[order]; 
    signal output results[order];
    
    results <== NTT(order, primeMod, rootList)(inputs); 
}
