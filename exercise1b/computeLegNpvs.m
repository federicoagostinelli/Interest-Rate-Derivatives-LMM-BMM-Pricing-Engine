function [npvA, npvBCorrected, npvBUncorrected] = computeLegNpvs( ...
    market, product, volsLMM)
%COMPUTELEGNPVS Compute present values of Party A and Party B legs.
%
%   [npvA, npvBCorrected, npvBUncorrected] = computeLegNpvs( ...
%       market, product, volsLMM)
%
%   computes the present values of the two coupon legs of the structured
%   bond, excluding the upfront amount.
%
%   Party A pays a quarterly Euribor 3M plus spread leg:
%
%       Euribor 3M + spreadA
%
%   Party B pays the structured coupon leg defined by product.rules.
%
%   The product is assumed to have already been prepared by:
%
%       product = prepareProductForPricing(product, market);
%
%   Therefore this function uses precomputed Party B schedule quantities:
%
%       product.partyB.paymentDiscounts
%       product.partyB.delta
%
%   Since both legs follow the same quarterly Euribor 3M schedule, the
%   Party A floating and spread legs are valued on the Party B payment
%   schedule.
%
%   The Party A floating leg is valued by the standard par floating-leg
%   identity:
%
%       sum_i P(0,T_i) * delta_i * F_i = 1 - P(0,T_N)
%
%   valid because the first reset date is the valuation date and the leg
%   starts at par on the market reference date.
%
%   INPUTS:
%       market
%           Market struct created by initializeInterestRateMarket.
%
%       product
%           Product struct created by initializeProductExercise1 and
%           enriched by prepareProductForPricing.
%
%       volsLMM
%           Calibrated LMM volatility matrix in decimal units. Rows are
%           aligned with market.tenor.resetTimes(2:end), because the first
%           already-fixed caplet is excluded from calibration.
%
%   OUTPUTS:
%       npvA
%           Present value of the Party A Euribor 3M plus spread leg, in EUR.
%
%       npvBCorrected
%           Present value of the Party B structured coupon leg using
%           smile-corrected digital probabilities, in EUR.
%
%       npvBUncorrected
%           Present value of the Party B structured coupon leg using
%           uncorrected Black-76 digital probabilities, in EUR.

    partyA = product.partyA;
    partyB = product.partyB;

    paymentDiscounts = partyB.paymentDiscounts(:);
    accrualFactors = partyB.delta(:);

    floatingLegA = 1.0 - paymentDiscounts(end);

    spreadLegA = ...
        partyA.spread ...
        * sum(accrualFactors .* paymentDiscounts);

    npvA = product.principal * (floatingLegA + spreadLegA);

    [npvBCorrected, npvBUncorrected] = computeNpvB( ...
        market, ...
        product, ...
        volsLMM);

end