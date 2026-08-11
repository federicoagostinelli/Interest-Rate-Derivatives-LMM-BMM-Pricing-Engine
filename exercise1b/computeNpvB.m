function [npvBCorrected, npvBUncorrected] = computeNpvB( ...
    market, product, volsModel)
%COMPUTENPVB Compute the present value of the Party B coupon leg.
%
%   [npvBCorrected, npvBUncorrected] = computeNpvB( ...
%       market, product, volsModel)
%
%   computes the present value of the Party B structured coupon leg,
%   excluding any upfront amount.
%
%   The product is assumed to have already been enriched with market-
%   dependent pricing quantities by:
%
%       product = prepareProductForPricing(product, market);
%
%   Therefore this function uses precomputed quantities from product.partyB:
%
%       paymentDates
%       resetTimes
%       delta
%       paymentDiscounts
%       forwardRates
%
%   and does not recompute schedules, accrual factors, discount factors or
%   forward rates.
%
%   The first Party B coupon is deterministic:
%
%       firstCoupon
%
%   and is paid at the first Party B payment date. All following coupons are
%   valued under the payoff:
%
%       (L + spread) * 1_{L <= barrier}
%       + elseCoupon * 1_{L > barrier}
%
%   Equivalently:
%
%       L + spread
%       - (L - barrier)^+
%       - (barrier + spread - elseCoupon) * 1_{L > barrier}
%
%   volsModel is assumed to be already expressed in decimal units. Its
%   columns correspond to:
%
%       market.surface.strikes
%
%   Its rows correspond to the calibrated LMM reset-time grid excluding the
%   first already-fixed caplet:
%
%       market.tenor.resetTimes(2:end)
%
%   Therefore:
%
%       volsModel(1,:) corresponds to caplet 2
%       volsModel(2,:) corresponds to caplet 3
%       ...
%
%   Volatility smiles are linearly interpolated in reset time onto the
%   Party B reset times. Since the first coupon is deterministic, no
%   volatility is required for resetTimes(1).
%
%   INPUTS:
%       market
%           Market struct created by initializeInterestRateMarket.
%
%       product
%           Product struct created by initializeProductExercise1 and then
%           enriched by prepareProductForPricing.
%
%       volsModel
%           Calibrated LMM volatility matrix in decimal units, with rows
%           aligned to market.tenor.resetTimes(2:end) and columns aligned
%           to market.surface.strikes.
%
%   OUTPUTS:
%       npvBCorrected
%           Party B coupon-leg NPV using smile-corrected digital
%           probabilities, in EUR.
%
%       npvBUncorrected
%           Party B coupon-leg NPV using uncorrected Black-76 digital
%           probabilities, in EUR.

    partyB = product.partyB;

    %% Precomputed product quantities

    paymentDates = partyB.paymentDates(:);
    numberOfCoupons = numel(paymentDates);

    resetTimes = partyB.resetTimes(:);
    deltaT = partyB.delta(:);
    paymentDiscounts = partyB.paymentDiscounts(:);
    forwardRates = partyB.forwardRates(:);

    %% Market and model quantities

    marketStrikes = market.surface.strikes(:);

    modelResetTimes = market.tenor.resetTimes(2:end);
    modelResetTimes = modelResetTimes(:);

    %% Coupon parameters

    [spreadB, barrier, elseCoupon] = computeParameters( ...
        product.startDate, ...
        paymentDates, ...
        product.rules);

    spreadB = spreadB(:);
    barrier = barrier(:);
    elseCoupon = elseCoupon(:);

    %% Interpolate volatility smiles onto structured coupon reset times

    structuredIdx = 2:numberOfCoupons;

    volsAtResetTimes = zeros(numberOfCoupons, numel(marketStrikes));

    volsAtResetTimes(structuredIdx, :) = interp1( ...
        modelResetTimes, ...
        volsModel, ...
        resetTimes(structuredIdx), ...
        'linear', ...
        'extrap');

    %% First coupon is deterministic

    fixedCouponPv = ...
        product.principal ...
        * paymentDiscounts(1) ...
        * deltaT(1) ...
        * partyB.firstCoupon;

    %% Structured coupons

    couponPvCorrected = zeros(numberOfCoupons, 1);
    couponPvUncorrected = zeros(numberOfCoupons, 1);

    for couponIdx = structuredIdx

        [couponPvCorrected(couponIdx), couponPvUncorrected(couponIdx)] = ...
            pricePartyBCouponBlack( ...
                paymentDiscounts(couponIdx), ...
                forwardRates(couponIdx), ...
                deltaT(couponIdx), ...
                resetTimes(couponIdx), ...
                spreadB(couponIdx), ...
                barrier(couponIdx), ...
                elseCoupon(couponIdx), ...
                volsAtResetTimes(couponIdx, :), ...
                marketStrikes);

    end

    %% Total Party B NPV in EUR

    npvBCorrected = ...
        fixedCouponPv ...
        + product.principal * sum(couponPvCorrected(structuredIdx));

    npvBUncorrected = ...
        fixedCouponPv ...
        + product.principal * sum(couponPvUncorrected(structuredIdx));

end