function printExercise1eReport( ...
    useSmileCorrection, upfront, mtmBase, bucketNames, bucketDv01Bond, ...
    swapDv01Matrix, hedgeNotionalsBackward, hedgeNotionalsExact, ...
    residualDv01Backward, residualDv01Exact)
%PRINTEXERCISE1EREPORT Print coarse-grained bucket hedge diagnostics.
%
%   printExercise1eReport( ...
%       useSmileCorrection, upfront, mtmBase, bucketNames, bucketDv01Bond, ...
%       swapDv01Matrix, hedgeNotionalsBackward, hedgeNotionalsExact, ...
%       residualDv01Backward, residualDv01Exact)
%
%   prints the Exercise 1e hedge diagnostics:
%
%       - selected pricing convention;
%       - upfront used;
%       - base MtM;
%       - structured bond coarse bucket DV01s;
%       - swap DV01 matrix;
%       - assignment-style backward hedge notionals;
%       - residual DV01s for the backward hedge;
%       - exact linear-system hedge notionals;
%       - residual DV01s for the exact hedge.
%
%   INPUTS:
%       useSmileCorrection
%           true for smile-corrected pricing; false for uncorrected
%           Black-76 pricing.
%
%       upfront
%           Upfront percentage used in the MtM calculations.
%
%       mtmBase
%           Base mark-to-market value, in EUR.
%
%       bucketNames
%           Cell array of bucket labels.
%
%       bucketDv01Bond
%           Column vector of structured bond coarse bucket DV01s.
%
%       swapDv01Matrix
%           Matrix of swap DV01s. Rows are buckets and columns are swaps.
%
%       hedgeNotionalsBackward
%           Column vector of assignment-style hedge swap notionals.
%
%       hedgeNotionalsExact
%           Column vector of exact linear-system hedge swap notionals.
%
%       residualDv01Backward
%           Column vector of residual bucket DV01s after backward hedge.
%
%       residualDv01Exact
%           Column vector of residual bucket DV01s after exact hedge.
%
%   OUTPUT:
%       None. This function prints to the command window.

    nBuckets = numel(bucketNames);

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' Exercise 1e - Coarse-Grained Bucket Hedge\n');
    fprintf('============================================================\n');
    fprintf('Pricing convention       : %s\n', ...
        getPricingLabel(useSmileCorrection));
    fprintf('Upfront used             : %.8f %%\n', ...
        100.0 * upfront);
    fprintf('Base MtM                 : %.6f EUR\n', mtmBase);

    fprintf('------------------------------------------------------------\n');
    fprintf(' Structured bond coarse bucket DV01\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('%12s %18s\n', 'Bucket', 'DV01 EUR');

    for bucketIdx = 1:nBuckets
        fprintf('%12s %18.6f\n', ...
            bucketNames{bucketIdx}, ...
            bucketDv01Bond(bucketIdx));
    end

    fprintf('------------------------------------------------------------\n');
    fprintf(' Swap DV01 matrix A\n');
    fprintf(' Rows: buckets, columns: 2y / 6y / 10y swaps\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('%12s %18s %18s %18s\n', ...
        'Bucket', ...
        'Swap 2y', ...
        'Swap 6y', ...
        'Swap 10y');

    for bucketIdx = 1:nBuckets
        fprintf('%12s %18.6f %18.6f %18.6f\n', ...
            bucketNames{bucketIdx}, ...
            swapDv01Matrix(bucketIdx, 1), ...
            swapDv01Matrix(bucketIdx, 2), ...
            swapDv01Matrix(bucketIdx, 3));
    end

    fprintf('------------------------------------------------------------\n');
    fprintf(' Hedge notionals - backward substitution\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('Notional payer swap 2y   : %.2f EUR\n', ...
        hedgeNotionalsBackward(1));
    fprintf('Notional payer swap 6y   : %.2f EUR\n', ...
        hedgeNotionalsBackward(2));
    fprintf('Notional payer swap 10y  : %.2f EUR\n', ...
        hedgeNotionalsBackward(3));

    fprintf('------------------------------------------------------------\n');
    fprintf(' Residual bucket DV01 - backward substitution\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('%12s %18s\n', 'Bucket', 'Residual EUR');

    for bucketIdx = 1:nBuckets
        fprintf('%12s %18.8f\n', ...
            bucketNames{bucketIdx}, ...
            residualDv01Backward(bucketIdx));
    end

    fprintf('------------------------------------------------------------\n');
    fprintf(' Hedge notionals - exact linear solve\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('Notional payer swap 2y   : %.2f EUR\n', ...
        hedgeNotionalsExact(1));
    fprintf('Notional payer swap 6y   : %.2f EUR\n', ...
        hedgeNotionalsExact(2));
    fprintf('Notional payer swap 10y  : %.2f EUR\n', ...
        hedgeNotionalsExact(3));

    fprintf('------------------------------------------------------------\n');
    fprintf(' Residual bucket DV01 - exact linear solve\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('%12s %18s\n', 'Bucket', 'Residual EUR');

    for bucketIdx = 1:nBuckets
        fprintf('%12s %18.8f\n', ...
            bucketNames{bucketIdx}, ...
            residualDv01Exact(bucketIdx));
    end

    fprintf('============================================================\n\n');

end