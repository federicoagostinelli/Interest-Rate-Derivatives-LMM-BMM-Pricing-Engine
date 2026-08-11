function results = computeVega( ...
    marketBase, productBase, upfront, bumpVol, useSmileCorrection)
%COMPUTEVEGA Compute total market Vega by bumping the flat vol surface.
%
%   results = computeVega( ...
%       marketBase, productBase, upfront, bumpVol, useSmileCorrection)
%
%   computes the total Vega of the structured bond with respect to a
%   parallel shift of the quoted flat Black cap volatility surface.
%
%   The Vega is computed by central finite difference:
%
%       dMtM/dSigma ≈ [MtM(vols + bumpVol) - MtM(vols - bumpVol)]
%                    / (2 * bumpVol)
%
%   where bumpVol is an absolute volatility bump in decimal units.
%
%   The function bumps:
%
%       marketBase.surface.vols
%
%   then recalibrates the LMM volatility matrix in each bumped market:
%
%       volsLMMUp   = calibrateLMM(marketUp)
%       volsLMMDown = calibrateLMM(marketDown)
%
%   and finally reprices the product using computeMtm.
%
%   INPUTS:
%       marketBase
%           Base market struct.
%
%       productBase
%           Product struct already prepared on marketBase.
%
%       upfront
%           Upfront percentage used in the selected pricing convention.
%
%       bumpVol
%           Absolute volatility bump in decimal units. For example:
%
%               1 bp vol    = 1.0e-4
%               1% vol      = 1.0e-2
%
%       useSmileCorrection
%           Pricing convention selector:
%
%               true
%                   Use smile-corrected Party B pricing.
%
%               false
%                   Use uncorrected Black-76 Party B pricing.
%
%   OUTPUT:
%       results
%           Struct containing:
%
%               bumpVol
%               pricingLabel
%               mtmUp
%               mtmDown
%               vegaPerUnitVol
%               vegaPerBpVol
%               vegaPerOnePercentVol
%               volsLMMUp
%               volsLMMDown
%
%   NOTES:
%       vegaPerUnitVol is sensitivity to a 1.00 absolute volatility move.
%       vegaPerBpVol is sensitivity to a 1 bp volatility move.
%       vegaPerOnePercentVol is sensitivity to a 1% volatility move.

    if nargin < 3 || isempty(upfront)
        upfront = 0.0;
    end

    if nargin < 4 || isempty(bumpVol)
        bumpVol = 1.0e-4;
    end

    if nargin < 5 || isempty(useSmileCorrection)
        useSmileCorrection = true;
    end

    oneBpVol = 1.0e-4;
    onePercentVol = 1.0e-2;

    %% Bumped volatility markets

    marketUp = marketBase;
    marketDown = marketBase;

    marketUp.surface.vols = ...
        marketBase.surface.vols + bumpVol;

    marketDown.surface.vols = ...
        marketBase.surface.vols - bumpVol;

    %% Recalibrate LMM volatilities

    volsLMMUp = calibrateLMM(marketUp);
    volsLMMDown = calibrateLMM(marketDown);

    %% Reprice under bumped volatilities

    [mtmUpCorrected, mtmUpUncorrected] = computeMtm( ...
        marketBase, ...
        productBase, ...
        volsLMMUp, ...
        upfront, ...
        upfront);

    [mtmDownCorrected, mtmDownUncorrected] = computeMtm( ...
        marketBase, ...
        productBase, ...
        volsLMMDown, ...
        upfront, ...
        upfront);

    mtmUp = selectMtM( ...
        mtmUpCorrected, ...
        mtmUpUncorrected, ...
        useSmileCorrection);

    mtmDown = selectMtM( ...
        mtmDownCorrected, ...
        mtmDownUncorrected, ...
        useSmileCorrection);

    %% Central finite difference

    vegaPerUnitVol = ...
        (mtmUp - mtmDown) / (2.0 * bumpVol);

    vegaPerBpVol = ...
        vegaPerUnitVol * oneBpVol;

    vegaPerOnePercentVol = ...
        vegaPerUnitVol * onePercentVol;

    %% Store results

    results = struct();

    results.bumpVol = bumpVol;
    results.useSmileCorrection = useSmileCorrection;
    results.pricingLabel = getPricingLabel(useSmileCorrection);

    results.upfront = upfront;
    results.upfrontAmount = upfront * productBase.principal;

    results.mtmUp = mtmUp;
    results.mtmDown = mtmDown;

    results.vegaPerUnitVol = vegaPerUnitVol;
    results.vegaPerBpVol = vegaPerBpVol;
    results.vegaPerOnePercentVol = vegaPerOnePercentVol;

    results.volsLMMUp = volsLMMUp;
    results.volsLMMDown = volsLMMDown;
    results.volsLMMDiff = volsLMMUp - volsLMMDown;

end