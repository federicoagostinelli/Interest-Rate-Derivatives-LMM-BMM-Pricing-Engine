function [mtmCorrected, mtmUncorrected] = computeMtm( ...
    market, product, volsLMM, upfrontCorrected, upfrontUncorrected)
%COMPUTEMTM Compute the mark-to-market value of the structured bond.
%
%   [mtmCorrected, mtmUncorrected] = computeMtm( ...
%       market, product, volsLMM, upfrontCorrected, upfrontUncorrected)
%
%   computes the mark-to-market value of the transaction under both Party B
%   pricing conventions:
%
%       - smile-corrected digital probabilities;
%       - uncorrected Black-76 digital probabilities.
%
%   The product is assumed to have already been enriched with pricing
%   quantities by:
%
%       product = prepareProductForPricing(product, market);
%
%   The mark-to-market convention is:
%
%       MtM = NPV_A - NPV_B - upfront * principal
%
%   where:
%
%       NPV_A
%           Present value of the Euribor 3M plus spread leg paid by Party A.
%
%       NPV_B
%           Present value of the structured coupon leg paid by Party B,
%           excluding the upfront amount.
%
%       upfront
%           Upfront percentage paid by Party B at inception.
%
%       principal
%           Contract principal amount.
%
%   With this convention, the fair upfront satisfies:
%
%       upfront = (NPV_A - NPV_B) / principal
%
%   and therefore makes:
%
%       MtM = 0
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
%       upfrontCorrected
%           Upfront percentage used with smile-corrected Party B pricing.
%           If omitted, it is set to zero.
%
%       upfrontUncorrected
%           Upfront percentage used with uncorrected Black-76 Party B
%           pricing. If omitted, it is set equal to upfrontCorrected.
%
%   OUTPUTS:
%       mtmCorrected
%           Mark-to-market value using smile-corrected Party B pricing, in
%           EUR.
%
%       mtmUncorrected
%           Mark-to-market value using uncorrected Black-76 Party B pricing,
%           in EUR.

    if nargin < 4
        upfrontCorrected = 0.0;
        upfrontUncorrected = 0.0;
    elseif nargin < 5
        upfrontUncorrected = upfrontCorrected;
    end

    [npvA, npvBCorrected, npvBUncorrected] = computeLegNpvs( ...
        market, ...
        product, ...
        volsLMM);

    mtmCorrected = ...
        npvA ...
        - npvBCorrected ...
        - upfrontCorrected * product.principal;

    mtmUncorrected = ...
        npvA ...
        - npvBUncorrected ...
        - upfrontUncorrected * product.principal;

end