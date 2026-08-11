function results = computeDV01Bucket( ...
    datesSet, ratesSet, volsLMMBase, marketBase, ...
    productBase, productContract, upfront, bp, useSmileCorrection)
%COMPUTEDV01BUCKET Compute bucket DV01 sensitivities.
%
%   results = computeDV01Bucket( ...
%       datesSet, ratesSet, volsLMMBase, marketBase, ...
%       productBase, productContract, upfront, bp, useSmileCorrection)
%
%   computes bucket DV01 sensitivities by shocking one bootstrap bucket at a
%   time.
%
%   The reference date is assumed to be unchanged by the curve shock.
%   Therefore the shocked market has the same tenor date grid and reset-time
%   grid as the base market:
%
%       marketUp.tenor.dates      = marketBase.tenor.dates
%       marketUp.tenor.resetTimes = marketBase.tenor.resetTimes
%
%   This makes the base calibrated LMM volatility matrix usable on shocked
%   markets for the partial DV01 calculation.
%
%   Two DV01 measures are reported:
%
%       partialDV01
%           Curve-only DV01. The shocked curve is used for discounting and
%           forward rates, while the base calibrated LMM volatilities are
%           kept fixed.
%
%       totalDV01
%           Curve-plus-recalibration DV01. The shocked curve is used for
%           discounting and forward rates, and the LMM volatility matrix is
%           recalibrated on the shocked market.
%
%   DV01 values are normalized to EUR per 1 bp:
%
%       DV01 = (MtM_shocked - MtM_base) * oneBp / shockSize
%
%   where:
%
%       oneBp = 1.0e-4
%
%   INPUTS:
%       datesSet
%           Bootstrap instrument dates used by bootstrapShocked.
%
%       ratesSet
%           Bootstrap market rates used by bootstrapShocked.
%
%       volsLMMBase
%           Base calibrated LMM volatility matrix in decimal units. Rows are
%           aligned with marketBase.tenor.resetTimes(2:end), because the
%           first already-fixed caplet is excluded from calibration.
%
%       marketBase
%           Base market struct.
%
%       productBase
%           Product struct already prepared on marketBase.
%
%       productContract
%           Contractual product struct, not yet prepared on the shocked
%           markets.
%
%       upfront
%           Upfront percentage used in the selected pricing convention.
%           If omitted or empty, zero is used.
%
%       bp
%           Shock size in absolute rate units. For example:
%
%               1 bp    = 1.0e-4
%               0.1 bp  = 1.0e-5
%               0.01 bp = 1.0e-6
%
%           If omitted or empty, 1 bp is used.
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
%           If omitted or empty, true is used.
%
%   OUTPUT:
%       results
%           Struct containing:
%
%               useSmileCorrection
%               pricingLabel
%               upfront
%               upfrontAmount
%               shockSize
%               bucketDates
%               bucketNames
%               nBuckets
%               mtmBase
%               partialMtmUp
%               totalMtmUp
%               partialDV01
%               totalDV01
%               diff
%               sumPartialDV01
%               sumTotalDV01
%               sumDiff
%               marketUp
%               productUp
%               volsLMMBase
%               volsLMMUp
%               volDiff
%               maxAbsVolDiff

    if nargin < 7 || isempty(upfront)
        upfront = 0.0;
    end

    if nargin < 8 || isempty(bp)
        bp = 1.0e-4;
    end

    if nargin < 9 || isempty(useSmileCorrection)
        useSmileCorrection = true;
    end

    oneBp = 1.0e-4;

    %% Base MtM

    [mtmBaseCorrected, mtmBaseUncorrected] = computeMtm( ...
        marketBase, ...
        productBase, ...
        volsLMMBase, ...
        upfront, ...
        upfront);

    mtmBase = selectMtM( ...
        mtmBaseCorrected, ...
        mtmBaseUncorrected, ...
        useSmileCorrection);

    %% Bucket pillars

    [bucketDates, bucketNames] = getBootstrapBucketPillars(datesSet);

    nBuckets = numel(bucketDates);

    %% Containers

    partialMtmUp = zeros(nBuckets, 1);
    totalMtmUp = zeros(nBuckets, 1);

    partialDV01 = zeros(nBuckets, 1);
    totalDV01 = zeros(nBuckets, 1);

    maxAbsVolDiff = zeros(nBuckets, 1);

    marketsUp = cell(nBuckets, 1);
    productsUp = cell(nBuckets, 1);

    volsLMMUpCell = cell(nBuckets, 1);
    volDiffCell = cell(nBuckets, 1);

    %% Bucket loop

    for bucketIdx = 1:nBuckets

        shockValues = zeros(nBuckets, 1);
        shockValues(bucketIdx) = bp;

        shockTable = timetable( ...
            bucketDates(:), ...
            shockValues(:), ...
            'VariableNames', {'Shock'});

        [datesUp, discountsUp, zeroRatesUp] = bootstrapShocked( ...
            datesSet, ...
            ratesSet, ...
            shockTable);

        marketUp = initializeInterestRateMarket( ...
            datesUp, ...
            discountsUp, ...
            zeroRatesUp);

        productUp = prepareProductForPricing( ...
            productContract, ...
            marketUp);

        marketsUp{bucketIdx} = marketUp;
        productsUp{bucketIdx} = productUp;

        %% Partial DV01: shocked curve, base LMM vols

        [partialMtmUpCorrected, partialMtmUpUncorrected] = computeMtm( ...
            marketUp, ...
            productUp, ...
            volsLMMBase, ...
            upfront, ...
            upfront);

        partialMtmUp(bucketIdx) = selectMtM( ...
            partialMtmUpCorrected, ...
            partialMtmUpUncorrected, ...
            useSmileCorrection);

        partialDV01(bucketIdx) = ...
            (partialMtmUp(bucketIdx) - mtmBase) * oneBp / bp;

        %% Total DV01: shocked curve, recalibrated LMM vols

        volsLMMUp = calibrateLMM(marketUp);

        volsLMMUpCell{bucketIdx} = volsLMMUp;

        [totalMtmUpCorrected, totalMtmUpUncorrected] = computeMtm( ...
            marketUp, ...
            productUp, ...
            volsLMMUp, ...
            upfront, ...
            upfront);

        totalMtmUp(bucketIdx) = selectMtM( ...
            totalMtmUpCorrected, ...
            totalMtmUpUncorrected, ...
            useSmileCorrection);

        totalDV01(bucketIdx) = ...
            (totalMtmUp(bucketIdx) - mtmBase) * oneBp / bp;

        volDiffCell{bucketIdx} = volsLMMUp - volsLMMBase;

        maxAbsVolDiff(bucketIdx) = max( ...
            abs(volDiffCell{bucketIdx}), ...
            [], ...
            'all');

    end

    %% Results

    results = struct();

    results.useSmileCorrection = useSmileCorrection;
    results.pricingLabel = getPricingLabel(useSmileCorrection);

    results.upfront = upfront;
    results.upfrontAmount = upfront * productContract.principal;

    results.shockSize = bp;

    results.bucketDates = bucketDates;
    results.bucketNames = bucketNames;
    results.nBuckets = nBuckets;

    results.mtmBase = mtmBase;

    results.partialMtmUp = partialMtmUp;
    results.totalMtmUp = totalMtmUp;

    results.partialDV01 = partialDV01;
    results.totalDV01 = totalDV01;
    results.diff = totalDV01 - partialDV01;

    results.sumPartialDV01 = sum(partialDV01);
    results.sumTotalDV01 = sum(totalDV01);
    results.sumDiff = results.sumTotalDV01 - results.sumPartialDV01;

    results.marketUp = marketsUp;
    results.productUp = productsUp;

    results.volsLMMBase = volsLMMBase;
    results.volsLMMUp = volsLMMUpCell;
    results.volDiff = volDiffCell;
    results.maxAbsVolDiff = maxAbsVolDiff;

    %% Print report

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('LMM Bucket DV01 Diagnostics\n');
    fprintf('============================================================\n');
    fprintf('Pricing convention      : %s\n', results.pricingLabel);
    fprintf('Shock size              : %.4f bp\n', bp / oneBp);
    fprintf('DV01 units              : EUR / bp\n');
    fprintf('Upfront used            : %.8f %%\n', 100 * upfront);
    fprintf('Upfront amount          : %.2f EUR\n', results.upfrontAmount);
    fprintf('Base MtM                : %.6f EUR\n', mtmBase);
    fprintf('------------------------------------------------------------\n');
    fprintf('%5s %14s %18s %15s %15s %15s %15s\n', ...
        'Idx', ...
        'Date', ...
        'Bucket', ...
        'PartialDV01', ...
        'TotalDV01', ...
        'Total-Partial', ...
        'MaxVolDiff');

    for bucketIdx = 1:nBuckets

        if abs(partialDV01(bucketIdx)) > 1.0e-8 ...
                || abs(totalDV01(bucketIdx)) > 1.0e-8

            fprintf('%5d %14s %18s %15.6f %15.6f %15.6f %15.6e\n', ...
                bucketIdx, ...
                datestr(bucketDates(bucketIdx), 'dd-mmm-yyyy'), ...
                bucketNames{bucketIdx}, ...
                partialDV01(bucketIdx), ...
                totalDV01(bucketIdx), ...
                totalDV01(bucketIdx) - partialDV01(bucketIdx), ...
                maxAbsVolDiff(bucketIdx));

        end

    end

    fprintf('------------------------------------------------------------\n');
    fprintf('Sum Partial DV01        : %.6f EUR / bp\n', ...
        results.sumPartialDV01);

    fprintf('Sum Total DV01          : %.6f EUR / bp\n', ...
        results.sumTotalDV01);

    fprintf('Sum Total - Partial     : %.6f EUR / bp\n', ...
        results.sumDiff);

    fprintf('============================================================\n\n');

end