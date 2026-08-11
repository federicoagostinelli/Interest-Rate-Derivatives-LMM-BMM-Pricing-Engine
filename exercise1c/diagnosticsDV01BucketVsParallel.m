function diagnosticsDV01BucketVsParallel(parallelResults, bucketResults)
%DIAGNOSTICSDV01BUCKETVSPARALLEL Compare parallel DV01 with sum of bucket DV01.

    sumPartialBucket = sum(bucketResults.partialDV01);
    sumTotalBucket   = sum(bucketResults.totalDV01);

    partialDiff = sumPartialBucket - parallelResults.partialDV01;
    totalDiff   = sumTotalBucket   - parallelResults.totalDV01;

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('Bucket DV01 vs Parallel DV01 Diagnostics\n');
    fprintf('============================================================\n');
    fprintf('Parallel partial DV01     : %.6f EUR / bp\n', parallelResults.partialDV01);
    fprintf('Sum bucket partial DV01   : %.6f EUR / bp\n', sumPartialBucket);
    fprintf('Difference partial        : %.6f EUR / bp\n', partialDiff);
    fprintf('------------------------------------------------------------\n');
    fprintf('Parallel total DV01       : %.6f EUR / bp\n', parallelResults.totalDV01);
    fprintf('Sum bucket total DV01     : %.6f EUR / bp\n', sumTotalBucket);
    fprintf('Difference total          : %.6f EUR / bp\n', totalDiff);
    fprintf('============================================================\n\n');

end