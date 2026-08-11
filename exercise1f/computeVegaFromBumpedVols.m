function vega = computeVegaFromBumpedVols( ...
    market, product, volsLmmUp, volsLmmDown, upfront, ...
    bumpVol, reportedVolShift, useSmileCorrection)
%COMPUTEVEGAFROMBUMPEDVOLS Compute finite-difference Vega from LMM vols.
%
%   vega = computeVegaFromBumpedVols( ...
%       market, product, volsLmmUp, volsLmmDown, upfront, ...
%       bumpVol, reportedVolShift, useSmileCorrection)
%
%   reprices the product with up and down LMM volatility matrices and
%   computes the centered finite-difference Vega scaled to reportedVolShift.
%
%   INPUTS:
%       market
%           Base market struct.
%
%       product
%           Product struct prepared on market.
%
%       volsLmmUp
%           LMM volatility matrix calibrated from the bumped-up surface.
%
%       volsLmmDown
%           LMM volatility matrix calibrated from the bumped-down surface.
%
%       upfront
%           Upfront percentage used in the MtM calculation.
%
%       bumpVol
%           Technical volatility bump used in finite difference.
%
%       reportedVolShift
%           Volatility shift used for reporting, e.g. 0.01 for 1%.
%
%       useSmileCorrection
%           true selects smile-corrected MtM; false selects uncorrected
%           Black-76 MtM.
%
%   OUTPUT:
%       vega
%           Vega in EUR for the reportedVolShift.

    mtmUp = computeSelectedMtm( ...
        market, ...
        product, ...
        volsLmmUp, ...
        upfront, ...
        useSmileCorrection);

    mtmDown = computeSelectedMtm( ...
        market, ...
        product, ...
        volsLmmDown, ...
        upfront, ...
        useSmileCorrection);

    vega = ...
        (mtmUp - mtmDown) ...
        / (2.0 * bumpVol) ...
        * reportedVolShift;

end