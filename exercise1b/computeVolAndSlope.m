function [sigma, slope] = computeVolAndSlope(strikes, volsAtResetTimes, strike)
%COMPUTEVOLANDSLOPE Interpolate volatility and smile slope at a strike.
%
%   [sigma, slope] = computeVolAndSlope(strikes, volsAtResetTimes, strike)
%
%   interpolates the volatility smile at the requested strike and computes
%   the local smile slope:
%
%       dSigma / dK
%
%   using a centered finite difference around the strike.
%
%   The interpolation is performed with cubic splines over the strike grid:
%
%       sigma(K) = spline interpolation of volsAtResetTimes at K
%
%   and the slope is approximated as:
%
%       dSigma/dK ≈ [sigma(K + h) - sigma(K - h)] / (2h)
%
%   with:
%
%       h = 1.0e-4
%
%   corresponding to a 1 basis point strike shift when rates are expressed
%   in decimal units.
%
%   INPUTS:
%       strikes
%           Strike grid in decimal units.
%
%       volsAtResetTimes
%           Volatility smile in decimal units. Each row corresponds to one
%           reset time and each column corresponds to one strike.
%
%       strike
%           Strike or barrier where the volatility and smile slope are
%           evaluated, in decimal units.
%
%   OUTPUTS:
%       sigma
%           Interpolated volatility at strike.
%
%       slope
%           Local volatility slope dSigma/dK at strike.
%
%   ASSUMPTIONS:
%       - strikes are expressed in decimal units.
%       - volsAtResetTimes are expressed in decimal units.
%       - strike is expressed in decimal units.
%       - volsAtResetTimes has one column per strike.
%       - Spline extrapolation is allowed outside the quoted strike range.
%       - Outputs are returned as row vectors.

    strikeShift = 1.0e-4;

    strikes = strikes(:);
    volsAtResetTimes = reshape( ...
        volsAtResetTimes, ...
        [], ...
        numel(strikes));

    sigma = interp1( ...
        strikes, ...
        volsAtResetTimes.', ...
        strike, ...
        'spline', ...
        'extrap');

    sigmaUp = interp1( ...
        strikes, ...
        volsAtResetTimes.', ...
        strike + strikeShift, ...
        'spline', ...
        'extrap');

    sigmaDown = interp1( ...
        strikes, ...
        volsAtResetTimes.', ...
        strike - strikeShift, ...
        'spline', ...
        'extrap');

    slope = ...
        (sigmaUp - sigmaDown) ...
        ./ (2.0 * strikeShift);

    sigma = sigma(:).';
    slope = slope(:).';

end