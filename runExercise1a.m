function results = runExercise1a(inputFileName, dateFormat)
%RUNEXERCISE1A Run discount-curve bootstrap and LMM calibration.
%
%   results = runExercise1a(inputFileName, dateFormat)
%
%   reads market curve data, bootstraps the discount curve, initializes the
%   market and the structured product, calibrates the LMM caplet volatility
%   matrix, and runs calibration diagnostics.
%
%   INPUTS:
%       inputFileName
%           Excel file containing bootstrap market data.
%
%       dateFormat
%           Date format used when reading the Excel data.
%
%   OUTPUT:
%       results
%           Struct containing:
%
%               curveDatesSet
%               curveRatesSet
%               curveDates
%               curveDiscounts
%               curveZeroRates
%               marketBaseLmm
%               productContract
%               productBase
%               volsLmmBase
%               calibrationReportLmm

    if nargin < 1 || isempty(inputFileName)
        inputFileName = 'MktData_CurveBootstrap.xls';
    end

    if nargin < 2 || isempty(dateFormat)
        dateFormat = 'dd-mmm-yy';
    end

    %% Read and bootstrap the discount curve

    [curveDatesSet, curveRatesSet] = readExcelData( ...
        inputFileName, ...
        dateFormat);

    [curveDates, curveDiscounts, curveZeroRates] = bootstrap( ...
        curveDatesSet, ...
        curveRatesSet);

    %% Market and product initialization

    marketBaseLmm = initializeInterestRateMarket( ...
        curveDates, ...
        curveDiscounts, ...
        curveZeroRates);

    productContract = initializeProductExercise1(marketBaseLmm);

    productBase = prepareProductForPricing( ...
        productContract, ...
        marketBaseLmm);

    %% LMM calibration

    volsLmmBase = calibrateLMM(marketBaseLmm);

    %% LMM calibration diagnostics

    plotCalibratedVolsSelected( ...
        marketBaseLmm.tenor.dates, ...
        volsLmmBase, ...
        marketBaseLmm.surface, ...
        [0.02 0.05 0.08], ...
        'LMM');

    calibrationReportLmm = printCalibrationReport( ...
        marketBaseLmm.tenor.dates, ...
        marketBaseLmm.tenor.discounts, ...
        marketBaseLmm.surface, ...
        volsLmmBase, ...
        'LMM');

    plotVolSurface3D( ...
        marketBaseLmm.tenor.dates, ...
        volsLmmBase, ...
        marketBaseLmm.surface.strikes, ...
        'LMM');

    %% Store results

    results = struct();

    results.curveDatesSet = curveDatesSet;
    results.curveRatesSet = curveRatesSet;

    results.curveDates = curveDates;
    results.curveDiscounts = curveDiscounts;
    results.curveZeroRates = curveZeroRates;

    results.marketBaseLmm = marketBaseLmm;

    results.productContract = productContract;
    results.productBase = productBase;

    results.volsLmmBase = volsLmmBase;
    results.calibrationReportLmm = calibrationReportLmm;

end