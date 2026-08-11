function vega = computeCapVegaFromBumpedVols( ...
    market, volsLmmUp, volsLmmDown, strike, capMaturityYears, ...
    bumpVol, reportedVolShift)
%COMPUTECAPVEGAFROMBUMPEDVOLS Compute cap Vega by finite difference.
%
%   vega = computeCapVegaFromBumpedVols( ...
%       market, volsLmmUp, volsLmmDown, strike, capMaturityYears, ...
%       bumpVol, reportedVolShift)
%
%   prices the cap with bumped-up and bumped-down LMM volatilities and
%   computes the centered finite-difference Vega.
%
%   INPUTS:
%       market
%           Base market struct.
%
%       volsLmmUp
%           LMM volatilities calibrated from bumped-up surface.
%
%       volsLmmDown
%           LMM volatilities calibrated from bumped-down surface.
%
%       strike
%           Cap strike in decimal units.
%
%       capMaturityYears
%           Cap maturity in years.
%
%       bumpVol
%           Technical volatility bump used in finite difference.
%
%       reportedVolShift
%           Volatility shift used for reporting.
%
%   OUTPUT:
%       vega
%           Cap Vega in EUR per unit notional for reportedVolShift.

    capPriceUp = priceCapAtStrike( ...
        market, ...
        volsLmmUp, ...
        strike, ...
        capMaturityYears);

    capPriceDown = priceCapAtStrike( ...
        market, ...
        volsLmmDown, ...
        strike, ...
        capMaturityYears);

    vega = ...
        (capPriceUp - capPriceDown) ...
        / (2.0 * bumpVol) ...
        * reportedVolShift;

end