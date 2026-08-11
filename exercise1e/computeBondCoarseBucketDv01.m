function bucketDv01Bond = computeBondCoarseBucketDv01( ...
    shockedMarkets, shockedProducts, volsLmmBase, upfront, ...
    mtmBase, useSmileCorrection)
%COMPUTEBONDCOARSEBUCKETDV01 Compute structured bond coarse bucket DV01s.
%
%   bucketDv01Bond = computeBondCoarseBucketDv01( ...
%       shockedMarkets, shockedProducts, volsLmmBase, upfront, ...
%       mtmBase, useSmileCorrection)
%
%   computes the MtM change of the structured bond under each coarse bucket
%   curve shock, keeping the base LMM volatility matrix fixed.
%
%   INPUTS:
%       shockedMarkets
%           Cell array of shocked market structs.
%
%       shockedProducts
%           Cell array of products prepared on shockedMarkets.
%
%       volsLmmBase
%           Base calibrated LMM volatility matrix.
%
%       upfront
%           Upfront percentage used in the MtM calculation.
%
%       mtmBase
%           Base mark-to-market value.
%
%       useSmileCorrection
%           true selects smile-corrected MtM; false selects uncorrected
%           Black-76 MtM.
%
%   OUTPUT:
%       bucketDv01Bond
%           Column vector of structured bond DV01s for the coarse buckets,
%           in EUR for the shocks defined by the shock timetables.

    nBuckets = numel(shockedMarkets);

    bucketDv01Bond = zeros(nBuckets, 1);

    for bucketIdx = 1:nBuckets

        mtmShocked = computeSelectedMtm( ...
            shockedMarkets{bucketIdx}, ...
            shockedProducts{bucketIdx}, ...
            volsLmmBase, ...
            upfront, ...
            useSmileCorrection);

        bucketDv01Bond(bucketIdx) = ...
            mtmShocked - mtmBase;

    end

end