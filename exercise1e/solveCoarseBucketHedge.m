function [hedgeNotionalsBackward, hedgeNotionalsExact] = solveCoarseBucketHedge( ...
    bucketDv01Bond, swapDv01Matrix)
%SOLVECOARSEBUCKETHEDGE Solve swap notionals for coarse bucket hedge.
%
%   [hedgeNotionalsBackward, hedgeNotionalsExact] = solveCoarseBucketHedge( ...
%       bucketDv01Bond, swapDv01Matrix)
%
%   solves the hedge equation:
%
%       bucketDv01Bond + swapDv01Matrix * hedgeNotionals = 0
%
%   using two methods:
%
%       hedgeNotionalsBackward
%           Assignment-style backward substitution, starting from the
%           longest maturity swap.
%
%       hedgeNotionalsExact
%           Exact solution of the full 3x3 linear system.
%
%   The backward substitution follows the intended coarse-bucket logic:
%
%       - the 10y swap hedges the 6y-10y bucket first;
%       - the 6y swap hedges the 2y-6y bucket after accounting for the
%         10y swap contribution;
%       - the 2y swap hedges the 0y-2y bucket after accounting for the
%         6y and 10y swap contributions.
%
%   This assumes that the swap DV01 matrix is approximately triangular. If
%   the matrix is not exactly triangular, the backward solution can leave
%   small residual DV01s, while the exact solution eliminates them up to
%   numerical precision.
%
%   INPUTS:
%       bucketDv01Bond
%           Column vector [3 x 1] of structured bond coarse bucket DV01s.
%
%       swapDv01Matrix
%           Matrix [3 x 3] of swap DV01s. Rows are buckets and columns are
%           swaps ordered as 2y, 6y, 10y.
%
%   OUTPUTS:
%       hedgeNotionalsBackward
%           Column vector [3 x 1] of payer swap notionals ordered as
%           2y, 6y, 10y, obtained by backward substitution.
%
%       hedgeNotionalsExact
%           Column vector [3 x 1] of payer swap notionals ordered as
%           2y, 6y, 10y, obtained by solving the full linear system.

    hedgeNotionalsBackward = zeros(3, 1);

    hedgeNotionalsBackward(3) = ...
        -bucketDv01Bond(3) ...
        / swapDv01Matrix(3, 3);

    hedgeNotionalsBackward(2) = ...
        -(bucketDv01Bond(2) ...
        + swapDv01Matrix(2, 3) * hedgeNotionalsBackward(3)) ...
        / swapDv01Matrix(2, 2);

    hedgeNotionalsBackward(1) = ...
        -(bucketDv01Bond(1) ...
        + swapDv01Matrix(1, 2) * hedgeNotionalsBackward(2) ...
        + swapDv01Matrix(1, 3) * hedgeNotionalsBackward(3)) ...
        / swapDv01Matrix(1, 1);

    hedgeNotionalsExact = ...
        -swapDv01Matrix \ bucketDv01Bond;

end