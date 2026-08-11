function results = runExercise1f( ...
    marketBaseLmm, productBase, volsLmmBase, upfrontForRisk, ...
    useSmileCorrectionForRisk)
%RUNEXERCISE1F Run coarse-grained Vega bucket hedge with caps.
%
%   results = runExercise1f( ...
%       marketBaseLmm, productBase, volsLmmBase, upfrontForRisk, ...
%       useSmileCorrectionForRisk)
%
%   computes coarse-grained Vega buckets of the structured bond and hedges
%   them using ATM caps.
%
%   Vega buckets:
%
%       0y-6y
%       6y-10y
%
%   Hedge instruments:
%
%       ATM 6y cap
%       ATM 10y cap
%
%   The Vega buckets are computed by bumping the quoted flat Black cap
%   volatility surface, recalibrating the LMM volatility matrix, and
%   repricing the structured bond.
%
%   A technical volatility bump of 1 bp is used for the centered finite
%   difference. Reported Vegas are scaled to a 1% absolute volatility move,
%   consistently with Exercise 1d.
%
%   INPUTS:
%       marketBaseLmm
%           Base market struct.
%
%       productBase
%           Product struct prepared on marketBaseLmm.
%
%       volsLmmBase
%           Base calibrated LMM volatility matrix in decimal units.
%
%       upfrontForRisk
%           Upfront percentage used in the selected pricing convention. If
%           omitted or empty, zero is used.
%
%       useSmileCorrectionForRisk
%           true for smile-corrected pricing, false for uncorrected Black-76
%           pricing. If omitted or empty, true is used.
%
%   OUTPUT:
%       results
%           Struct containing:
%               useSmileCorrection
%               pricingLabel
%               upfront
%               bumpVol
%               reportedVolShift
%               bondVegaBuckets
%               capStrikes
%               vegaMatrix
%               capNotionalsBackward
%               capNotionalsExact
%               capNotionals
%               vegaResidualBackward
%               vegaResidualExact

    if nargin < 4 || isempty(upfrontForRisk)
        upfrontForRisk = 0.0;
    end

    if nargin < 5 || isempty(useSmileCorrectionForRisk)
        useSmileCorrectionForRisk = true;
    end

    %% Vega bump convention

    bumpVol = 1.0e-4;          % 1 bp vol
    reportedVolShift = 0.01;   % 1% vol

    %% Build bucket volatility shocks

    surfaceMaturityTimes = marketBaseLmm.surface.maturities(:);

    [vegaWeights6y, vegaWeights10y] = ...
        buildVegaShockWeights(surfaceMaturityTimes);

    shockedMarkets = buildVegaShockedMarkets( ...
        marketBaseLmm, ...
        vegaWeights6y, ...
        vegaWeights10y, ...
        bumpVol);

    %% Recalibrate LMM volatilities

    volsLmm6yUp = calibrateLMM(shockedMarkets.market6yUp);
    volsLmm6yDown = calibrateLMM(shockedMarkets.market6yDown);

    volsLmm10yUp = calibrateLMM(shockedMarkets.market10yUp);
    volsLmm10yDown = calibrateLMM(shockedMarkets.market10yDown);

    %% Structured bond Vega buckets

    vegaBond6y = computeVegaFromBumpedVols( ...
        marketBaseLmm, ...
        productBase, ...
        volsLmm6yUp, ...
        volsLmm6yDown, ...
        upfrontForRisk, ...
        bumpVol, ...
        reportedVolShift, ...
        useSmileCorrectionForRisk);

    vegaBond10y = computeVegaFromBumpedVols( ...
        marketBaseLmm, ...
        productBase, ...
        volsLmm10yUp, ...
        volsLmm10yDown, ...
        upfrontForRisk, ...
        bumpVol, ...
        reportedVolShift, ...
        useSmileCorrectionForRisk);

    bondVegaBuckets = [
        vegaBond6y
        vegaBond10y
    ];

    %% ATM cap hedge strikes

    strike6y = getSwapRate( ...
        marketBaseLmm, ...
        6, ...
        4, ...
        2);

    strike10y = getSwapRate( ...
        marketBaseLmm, ...
        10, ...
        4, ...
        2);

    capStrikes = [
        strike6y
        strike10y
    ];

    %% Cap hedge Vega matrix

    vegaMatrix = computeCapVegaMatrix( ...
        marketBaseLmm, ...
        volsLmm6yUp, ...
        volsLmm6yDown, ...
        volsLmm10yUp, ...
        volsLmm10yDown, ...
        capStrikes, ...
        bumpVol, ...
        reportedVolShift);

    %% Hedge notionals

    [capNotionalsBackward, capNotionalsExact] = solveVegaBucketHedge( ...
        bondVegaBuckets, ...
        vegaMatrix);

    vegaResidualBackward = ...
        bondVegaBuckets ...
        + vegaMatrix * capNotionalsBackward;

    vegaResidualExact = ...
        bondVegaBuckets ...
        + vegaMatrix * capNotionalsExact;

    %% Print report

    printExercise1fReport( ...
        useSmileCorrectionForRisk, ...
        upfrontForRisk, ...
        bumpVol, ...
        reportedVolShift, ...
        bondVegaBuckets, ...
        capStrikes, ...
        vegaMatrix, ...
        capNotionalsBackward, ...
        capNotionalsExact, ...
        vegaResidualBackward, ...
        vegaResidualExact);

    %% Store results

    results = struct();

    results.useSmileCorrection = useSmileCorrectionForRisk;
    results.pricingLabel = getPricingLabel(useSmileCorrectionForRisk);

    results.upfront = upfrontForRisk;
    results.upfrontAmount = upfrontForRisk * productBase.principal;

    results.bumpVol = bumpVol;
    results.reportedVolShift = reportedVolShift;

    results.vegaWeights6y = vegaWeights6y;
    results.vegaWeights10y = vegaWeights10y;

    results.bondVegaBuckets = bondVegaBuckets;

    results.capStrikes = capStrikes;
    results.vegaMatrix = vegaMatrix;

    results.capNotionalsBackward = capNotionalsBackward;
    results.capNotionalsExact = capNotionalsExact;

    % Compatibility alias: assignment-style hedge.
    results.capNotionals = capNotionalsBackward;

    results.vegaResidualBackward = vegaResidualBackward;
    results.vegaResidualExact = vegaResidualExact;

    % Compatibility alias: assignment-style residual.
    results.vegaResidual = vegaResidualBackward;

    results.shockedMarkets = shockedMarkets;

    results.volsLmmBase = volsLmmBase;
    results.volsLmm6yUp = volsLmm6yUp;
    results.volsLmm6yDown = volsLmm6yDown;
    results.volsLmm10yUp = volsLmm10yUp;
    results.volsLmm10yDown = volsLmm10yDown;

end