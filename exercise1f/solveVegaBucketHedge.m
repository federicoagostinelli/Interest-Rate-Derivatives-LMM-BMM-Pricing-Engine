function [capNotionalsBackward, capNotionalsExact] = solveVegaBucketHedge( ...
    bondVegaBuckets, vegaMatrix)
%SOLVEVEGABUCKETHEDGE Solve cap notionals for Vega bucket hedge.
%
%   [capNotionalsBackward, capNotionalsExact] = solveVegaBucketHedge( ...
%       bondVegaBuckets, vegaMatrix)
%
%   solves:
%
%       bondVegaBuckets + vegaMatrix * capNotionals = 0
%
%   using:
%
%       capNotionalsBackward
%           Assignment-style backward substitution.
%
%       capNotionalsExact
%           Exact 2 x 2 linear-system solution.
%
%   INPUTS:
%       bondVegaBuckets
%           Column vector [2 x 1] of structured bond Vega buckets.
%
%       vegaMatrix
%           Matrix [2 x 2]. Rows are Vega buckets and columns are hedge
%           caps ordered as 6y cap and 10y cap.
%
%   OUTPUTS:
%       capNotionalsBackward
%           Cap notionals obtained by backward substitution.
%
%       capNotionalsExact
%           Cap notionals obtained by solving the full linear system.

    capNotionalsBackward = zeros(2, 1);

    capNotionalsBackward(2) = ...
        -bondVegaBuckets(2) ...
        / vegaMatrix(2, 2);

    capNotionalsBackward(1) = ...
        -(bondVegaBuckets(1) ...
        + vegaMatrix(1, 2) * capNotionalsBackward(2)) ...
        / vegaMatrix(1, 1);

    capNotionalsExact = ...
        -vegaMatrix \ bondVegaBuckets;

end