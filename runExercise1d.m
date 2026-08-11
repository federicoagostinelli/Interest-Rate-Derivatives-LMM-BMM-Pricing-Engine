function results = runExercise1d( ...
    marketBaseLmm, productBase, upfrontForRisk, useSmileCorrectionForRisk)
%RUNEXERCISE1D Run total Vega analysis.
%
%   results = runExercise1d( ...
%       marketBaseLmm, productBase, upfrontForRisk, useSmileCorrectionForRisk)
%
%   computes and prints the total market Vega of the structured bond with
%   respect to a parallel bump of the quoted flat Black cap volatility
%   surface.
%
%   The Vega is computed by computeVega using a central finite difference:
%
%       Vega = [MtM(vols + bumpVol) - MtM(vols - bumpVol)]
%              / (2 * bumpVol)
%
%   The reported quantities are:
%
%       - EUR per 1 bp volatility move;
%       - EUR per 1% volatility move.
%
%   INPUTS:
%       marketBaseLmm
%           Base market struct.
%
%       productBase
%           Product struct prepared on marketBaseLmm.
%
%       upfrontForRisk
%           Upfront percentage used in the selected pricing convention.
%
%       useSmileCorrectionForRisk
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
%           Struct returned by computeVega.

    if nargin < 3 || isempty(upfrontForRisk)
        upfrontForRisk = 0.0;
    end

    if nargin < 4 || isempty(useSmileCorrectionForRisk)
        useSmileCorrectionForRisk = true;
    end

    %% Vega bump convention

    volBump = 1.0e-4;   % 1 bp vol

    %% Compute total Vega

    results = computeVega( ...
        marketBaseLmm, ...
        productBase, ...
        upfrontForRisk, ...
        volBump, ...
        useSmileCorrectionForRisk);

    %% Print report

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' Exercise 1d - Total Vega\n');
    fprintf('============================================================\n');
    fprintf('Pricing convention       : %s\n', results.pricingLabel);
    fprintf('Volatility bump          : %.4f bp vol\n', volBump / 1.0e-4);
    fprintf('Upfront used             : %.8f %%\n', 100.0 * upfrontForRisk);
    fprintf('Upfront amount           : %.2f EUR\n', results.upfrontAmount);
    fprintf('MtM up                   : %.6f EUR\n', results.mtmUp);
    fprintf('MtM down                 : %.6f EUR\n', results.mtmDown);
    fprintf('------------------------------------------------------------\n');
    fprintf('Total Vega               : %.6f EUR / bp vol\n', ...
        results.vegaPerBpVol);
    fprintf('Total Vega               : %.6f EUR / 1%% vol\n', ...
        results.vegaPerOnePercentVol);
    fprintf('============================================================\n\n');

end