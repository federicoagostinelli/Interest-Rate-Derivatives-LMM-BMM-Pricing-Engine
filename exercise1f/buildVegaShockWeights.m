function [shock6yVega, shock10yVega] = buildVegaShockWeights(times)
%BUILDVEGASHOCKWEIGHTS Build coarse-grained Vega shock weights.
%
%   [shock6yVega, shock10yVega] = buildVegaShockWeights(times)
%
%   builds two piecewise-linear Vega shock weight profiles on the input
%   expiry times:
%
%       0y-6y Vega bucket
%           Weight is 1 up to 6y, then linearly decreases to 0 at 10y.
%
%       6y-10y Vega bucket
%           Weight is 0 up to 6y, then linearly increases to 1 at 10y, and
%           remains flat at 1 beyond 10y.
%
%   The output weights are dimensionless and lie between 0 and 1.
%   They can be multiplied by an absolute volatility bump, for example:
%
%       volBump = 1.0e-4;   % 1 bp vol
%       volsUp = volsBase + volBump * shock6yVega;
%
%   INPUT:
%       times
%           Array of expiry/reset times, in years. These times should be
%           aligned with the rows of the volatility matrix being bumped.
%
%   OUTPUTS:
%       shock6yVega
%           Column vector of weights for the 0y-6y Vega bucket.
%
%       shock10yVega
%           Column vector of weights for the 6y-10y Vega bucket.

    times = times(:);

    shock6yVega = interp1( ...
        [6, 10], ...
        [1, 0], ...
        times, ...
        'linear', ...
        0);

    shock6yVega(times <= 6) = 1;

    shock10yVega = interp1( ...
        [6, 10], ...
        [0, 1], ...
        times, ...
        'linear', ...
        0);

    shock10yVega(times >= 10) = 1;

    shock6yVega = shock6yVega(:);
    shock10yVega = shock10yVega(:);

end