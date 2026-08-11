function results = runExercise1e( ...
    curveDatesSet, curveRatesSet, marketBaseLmm, productBase, ...
    productContract, volsLmmBase, upfrontForRisk, useSmileCorrectionForRisk)
%RUNEXERCISE1E Run coarse-grained bucket DV01 hedge with swaps.
%
%   results = runExercise1e( ...
%       curveDatesSet, curveRatesSet, marketBaseLmm, productBase, ...
%       productContract, volsLmmBase, upfrontForRisk, useSmileCorrectionForRisk)
%
%   computes coarse-grained bucket DV01s of the structured bond on:
%
%       0y-2y
%       2y-6y
%       6y-10y
%
%   and hedges them with payer swaps of maturities:
%
%       2y, 6y, 10y
%
%   Two hedge solutions are reported:
%
%       backward hedge
%           Assignment-style backward substitution, starting from the
%           longest swap.
%
%       exact hedge
%           Full 3x3 linear-system solution.
%
%   The backward hedge follows the intended coarse-bucket logic:
%
%       - the 10y swap hedges the 6y-10y bucket first;
%       - the 6y swap hedges the 2y-6y bucket after accounting for the
%         10y swap contribution;
%       - the 2y swap hedges the 0y-2y bucket after accounting for the
%         6y and 10y swap contributions.
%
%   The exact hedge is included as a diagnostic because the swap DV01 matrix
%   is usually only approximately triangular.
%
%   INPUTS:
%       curveDatesSet
%           Struct containing bootstrap instrument dates.
%
%       curveRatesSet
%           Struct containing bootstrap market quotes.
%
%       marketBaseLmm
%           Base market struct.
%
%       productBase
%           Product struct prepared on marketBaseLmm.
%
%       productContract
%           Contractual product struct, not yet prepared on shocked markets.
%
%       volsLmmBase
%           Base calibrated LMM volatility matrix in decimal units.
%
%       upfrontForRisk
%           Upfront percentage used in the selected pricing convention.
%           If omitted or empty, zero is used.
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
%               upfrontAmount
%               bucketNames
%               bucketDv01Bond
%               swapMaturities
%               swapDv01Matrix
%               hedgeNotionalsBackward
%               hedgeNotionalsExact
%               hedgeNotionals
%               residualDv01Backward
%               residualDv01Exact
%               residualDv01
%               mtmBase
%               shockTables
%               shockedMarkets
%               shockedProducts

    if nargin < 7 || isempty(upfrontForRisk)
        upfrontForRisk = 0.0;
    end

    if nargin < 8 || isempty(useSmileCorrectionForRisk)
        useSmileCorrectionForRisk = true;
    end

    %% Coarse bucket setup

    bucketNames = {
        '0y-2y'
        '2y-6y'
        '6y-10y'
    };

    swapMaturities = [2; 6; 10];

    %% Build shock tables

    refDate = datetime( ...
        curveDatesSet.settlement, ...
        'ConvertFrom', ...
        'datenum');

    pillarDates = buildBootstrapPillarDates(curveDatesSet);

    [shock2yTable, shock6yTable, shock10yTable] = ...
        buildCoarseShocksTable(pillarDates, refDate);

    shockTables = {
        shock2yTable
        shock6yTable
        shock10yTable
    };

    %% Base MtM

    mtmBase = computeSelectedMtm( ...
        marketBaseLmm, ...
        productBase, ...
        volsLmmBase, ...
        upfrontForRisk, ...
        useSmileCorrectionForRisk);

    %% Shocked markets and products

    [shockedMarkets, shockedProducts] = buildShockedMarketsAndProducts( ...
        curveDatesSet, ...
        curveRatesSet, ...
        shockTables, ...
        productContract);

    %% Structured bond coarse bucket DV01

    bucketDv01Bond = computeBondCoarseBucketDv01( ...
        shockedMarkets, ...
        shockedProducts, ...
        volsLmmBase, ...
        upfrontForRisk, ...
        mtmBase, ...
        useSmileCorrectionForRisk);

    %% Swap DV01 matrix

    swapDv01Matrix = computeSwapDv01Matrix( ...
        marketBaseLmm, ...
        shockedMarkets, ...
        swapMaturities);

    %% Hedge notionals and residual DV01

    [hedgeNotionalsBackward, hedgeNotionalsExact] = ...
        solveCoarseBucketHedge( ...
            bucketDv01Bond, ...
            swapDv01Matrix);

    residualDv01Backward = ...
        bucketDv01Bond ...
        + swapDv01Matrix * hedgeNotionalsBackward;

    residualDv01Exact = ...
        bucketDv01Bond ...
        + swapDv01Matrix * hedgeNotionalsExact;

    %% Print report

    printExercise1eReport( ...
        useSmileCorrectionForRisk, ...
        upfrontForRisk, ...
        mtmBase, ...
        bucketNames, ...
        bucketDv01Bond, ...
        swapDv01Matrix, ...
        hedgeNotionalsBackward, ...
        hedgeNotionalsExact, ...
        residualDv01Backward, ...
        residualDv01Exact);

    %% Store results

    results = struct();

    results.useSmileCorrection = useSmileCorrectionForRisk;
    results.pricingLabel = getPricingLabel(useSmileCorrectionForRisk);

    results.upfront = upfrontForRisk;
    results.upfrontAmount = upfrontForRisk * productContract.principal;

    results.bucketNames = bucketNames;
    results.bucketDv01Bond = bucketDv01Bond;

    results.swapMaturities = swapMaturities;
    results.swapDv01Matrix = swapDv01Matrix;

    results.hedgeNotionalsBackward = hedgeNotionalsBackward;
    results.hedgeNotionalsExact = hedgeNotionalsExact;

    % Compatibility alias: assignment-style hedge.
    results.hedgeNotionals = hedgeNotionalsBackward;

    results.residualDv01Backward = residualDv01Backward;
    results.residualDv01Exact = residualDv01Exact;

    % Compatibility alias: assignment-style residual.
    results.residualDv01 = residualDv01Backward;

    results.mtmBase = mtmBase;

    results.shockTables = shockTables;
    results.shockedMarkets = shockedMarkets;
    results.shockedProducts = shockedProducts;

end