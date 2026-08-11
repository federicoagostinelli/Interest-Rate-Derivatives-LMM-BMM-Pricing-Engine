function diagnosticsBucketCurveReconstruction(resultsParallel, bucketResults, marketBase)
%DIAGNOSTICSBUCKETCURVERECONSTRUCTION Check whether bucket shocks reconstruct parallel curve shock.

    discountsBase = marketBase.tenor.discounts(:);

    discountsParallel = resultsParallel.marketUp.tenor.discounts(:);
    parallelShift = discountsParallel - discountsBase;

    nBuckets = bucketResults.nBuckets;
    bucketShiftSum = zeros(size(discountsBase));

    for b = 1:nBuckets
        discountsBucket = bucketResults.marketUp{b}.tenor.discounts(:);
        bucketShiftSum = bucketShiftSum + (discountsBucket - discountsBase);
    end

    reconstructionError = bucketShiftSum - parallelShift;

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('Bucket Curve Reconstruction Diagnostics\n');
    fprintf('============================================================\n');
    fprintf('Max abs parallel discount shift : %.12e\n', max(abs(parallelShift)));
    fprintf('Max abs bucket-sum shift        : %.12e\n', max(abs(bucketShiftSum)));
    fprintf('Max abs reconstruction error    : %.12e\n', max(abs(reconstructionError)));
    fprintf('RMSE reconstruction error       : %.12e\n', sqrt(mean(reconstructionError.^2)));
    fprintf('============================================================\n\n');

    fprintf('%5s %14s %18s %18s %18s\n', ...
        'Idx', 'TenorDate', 'ParallelShift', 'BucketSumShift', 'Error');

    for i = 1:numel(discountsBase)
        fprintf('%5d %14s %18.10e %18.10e %18.10e\n', ...
            i, ...
            datestr(marketBase.tenor.dates(i), 'dd-mmm-yyyy'), ...
            parallelShift(i), ...
            bucketShiftSum(i), ...
            reconstructionError(i));
    end

    fprintf('\n');

end