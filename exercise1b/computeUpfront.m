function [upfrontCorrected, upfrontUncorrected, npvA, ...
          npvBCorrected, npvBUncorrected] = computeUpfront( ...
              market, product, volsLMM)
%COMPUTEUPFRONT Compute the fair upfront paid by Party B.
%
%   [upfrontCorrected, upfrontUncorrected, npvA, ...
%    npvBCorrected, npvBUncorrected] = computeUpfront( ...
%        market, product, volsLMM)
%
%   computes the fair upfront percentages that make the initial
%   mark-to-market of the structured bond equal to zero.
%
%   The product is assumed to have already been enriched with pricing
%   quantities by:
%
%       product = prepareProductForPricing(product, market);
%
%   The coupon-leg present values are computed by:
%
%       [npvA, npvBCorrected, npvBUncorrected] = computeLegNpvs( ...
%           market, product, volsLMM);
%
%   where:
%
%       npvA
%           Present value of the Party A Euribor 3M plus spread leg.
%
%       npvBCorrected
%           Present value of the Party B structured coupon leg using
%           smile-corrected digital probabilities.
%
%       npvBUncorrected
%           Present value of the Party B structured coupon leg using
%           uncorrected Black-76 digital probabilities.
%
%   The upfront is paid by Party B at inception. The fair value condition is:
%
%       MtM = NPV_A - NPV_B - upfront * principal = 0
%
%   Therefore:
%
%       upfront = (NPV_A - NPV_B) / principal
%
%   INPUTS:
%       market
%           Market struct created by initializeInterestRateMarket.
%
%       product
%           Product struct created by initializeProductExercise1 and then
%           enriched by prepareProductForPricing.
%
%       volsLMM
%           Calibrated LMM volatility matrix in decimal units. Rows are
%           aligned with market.tenor.resetTimes(2:end), because the first
%           already-fixed caplet is excluded from calibration.
%
%   OUTPUTS:
%       upfrontCorrected
%           Fair upfront percentage using smile-corrected Party B pricing.
%
%       upfrontUncorrected
%           Fair upfront percentage using uncorrected Black-76 Party B
%           pricing.
%
%       npvA
%           Present value of the Party A leg, in EUR.
%
%       npvBCorrected
%           Present value of the Party B leg using smile-corrected digital
%           probabilities, in EUR.
%
%       npvBUncorrected
%           Present value of the Party B leg using uncorrected Black-76
%           digital probabilities, in EUR.

    [npvA, npvBCorrected, npvBUncorrected] = computeLegNpvs( ...
        market, ...
        product, ...
        volsLMM);

    upfrontCorrected = ...
        (npvA - npvBCorrected) / product.principal;

    upfrontUncorrected = ...
        (npvA - npvBUncorrected) / product.principal;

end