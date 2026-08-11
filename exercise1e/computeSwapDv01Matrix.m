function swapDv01Matrix = computeSwapDv01Matrix( ...
    marketBase, shockedMarkets, swapMaturities)
%COMPUTESWAPDV01MATRIX Compute swap DV01 matrix for coarse buckets.
%
%   swapDv01Matrix = computeSwapDv01Matrix( ...
%       marketBase, shockedMarkets, swapMaturities)
%
%   computes the MtM change of each hedge swap under each coarse bucket
%   shock.
%
%   Rows correspond to shocked markets / coarse buckets.
%   Columns correspond to payer swaps with maturities swapMaturities.
%
%   Each swap is struck at its base par rate, so its base NPV is close to
%   zero. The reported value is:
%
%       pricePayerSwap(shockedMarket) - pricePayerSwap(baseMarket)
%
%   INPUTS:
%       marketBase
%           Base market struct.
%
%       shockedMarkets
%           Cell array of shocked market structs.
%
%       swapMaturities
%           Column vector of swap maturities in years.
%
%   OUTPUT:
%       swapDv01Matrix
%           Matrix with size [nBuckets x nSwaps]. Entry (i,j) is the MtM
%           change of swap j under bucket shock i.

    nBuckets = numel(shockedMarkets);
    nSwaps = numel(swapMaturities);

    swapDv01Matrix = zeros(nBuckets, nSwaps);

    for swapIdx = 1:nSwaps

        maturityYears = swapMaturities(swapIdx);

        swapRate = getSwapRate( ...
            marketBase, ...
            maturityYears, ...
            1, ...
            6);

        swapBaseNpv = pricePayerSwap( ...
            marketBase, ...
            maturityYears, ...
            1, ...
            swapRate);

        for bucketIdx = 1:nBuckets

            swapDv01Matrix(bucketIdx, swapIdx) = ...
                pricePayerSwap( ...
                    shockedMarkets{bucketIdx}, ...
                    maturityYears, ...
                    1, ...
                    swapRate) ...
                - swapBaseNpv;

        end

    end

end