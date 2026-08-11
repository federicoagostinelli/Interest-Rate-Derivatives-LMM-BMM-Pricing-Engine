function results = runExercise1bg(marketBaseLmm, productBase, productContract, volsLmmBase)
%RUNEXERCISE1B Compute fair upfront and digital smile risk.
%
%   results = runExercise1b( ...
%       marketBaseLmm, productBase, productContract, volsLmmBase)
%
%   computes the fair upfront of the structured bond under:
%
%       1. uncorrected Black-76 digital probability;
%       2. smile-corrected digital probability.
%
%   It also computes the corresponding mark-to-market checks and the digital
%   smile risk impact on the fair upfront.
%
%   INPUTS:
%       marketBaseLmm
%           Base market struct created by initializeInterestRateMarket.
%
%       productBase
%           Product struct already prepared by prepareProductForPricing.
%
%       productContract
%           Contractual product struct. Used here for the principal amount.
%
%       volsLmmBase
%           Base calibrated LMM volatility matrix in decimal units.
%
%   OUTPUT:
%       results
%           Struct containing:
%
%               upfrontCorrected
%               upfrontUncorrected
%               npvA
%               npvBCorrected
%               npvBUncorrected
%               mtmCorrected
%               mtmUncorrected
%               digitalRiskUpfront
%               digitalRiskAmount

    %% Fair upfront and leg NPVs

    [upfrontCorrected, upfrontUncorrected, ...
     npvA, npvBCorrected, npvBUncorrected] = computeUpfront( ...
        marketBaseLmm, ...
        productBase, ...
        volsLmmBase);

    %% Mark-to-market checks

    [mtmCorrected, mtmUncorrected] = computeMtm( ...
        marketBaseLmm, ...
        productBase, ...
        volsLmmBase, ...
        upfrontCorrected, ...
        upfrontUncorrected);

    %% Digital smile risk impact

    digitalRiskUpfront = upfrontCorrected - upfrontUncorrected;
    digitalRiskAmount = digitalRiskUpfront * productContract.principal;

    %% Print report

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' Exercise 1b and 1g - Fair Upfront and Digital Smile Risk\n');
    fprintf('============================================================\n');
    fprintf('Contract principal        : %.2f EUR\n', productContract.principal);
    fprintf('NPV Party A               : %.6f EUR\n', npvA);

    fprintf('------------------------------------------------------------\n');
    fprintf(' Uncorrected Black-76\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('NPV Party B uncorrected   : %.6f EUR\n', npvBUncorrected);
    fprintf('Fair upfront uncorrected  : %.6f%%\n', 100.0 * upfrontUncorrected);
    fprintf('Upfront amount uncorrected: %.2f EUR\n', ...
        upfrontUncorrected * productContract.principal);
    fprintf('MtM check uncorrected     : %.6f EUR\n', mtmUncorrected);

    fprintf('------------------------------------------------------------\n');
    fprintf(' Smile-corrected digital\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('NPV Party B corrected     : %.6f EUR\n', npvBCorrected);
    fprintf('Fair upfront corrected    : %.6f%%\n', 100.0 * upfrontCorrected);
    fprintf('Upfront amount corrected  : %.2f EUR\n', ...
        upfrontCorrected * productContract.principal);
    fprintf('MtM check corrected       : %.6f EUR\n', mtmCorrected);

    fprintf('------------------------------------------------------------\n');
    fprintf(' Digital risk impact\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('Upfront difference        : %+.6f%%\n', ...
        100.0 * digitalRiskUpfront);
    fprintf('Upfront difference        : %+.2f bp\n', ...
        10000.0 * digitalRiskUpfront);
    fprintf('Amount difference         : %+.2f EUR\n', digitalRiskAmount);
    fprintf('============================================================\n\n');

    %% Store results

    results = struct();

    results.upfrontCorrected = upfrontCorrected;
    results.upfrontUncorrected = upfrontUncorrected;

    results.npvA = npvA;
    results.npvBCorrected = npvBCorrected;
    results.npvBUncorrected = npvBUncorrected;

    results.mtmCorrected = mtmCorrected;
    results.mtmUncorrected = mtmUncorrected;

    results.digitalRiskUpfront = digitalRiskUpfront;
    results.digitalRiskAmount = digitalRiskAmount;

end