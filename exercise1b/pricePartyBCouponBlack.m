function [priceCorrected, priceUncorrected] = pricePartyBCouponBlack( ...
    paymentDiscount, forwardRate, accrualFactor, resetTime, ...
    spread, barrier, elseCoupon, volsAtResetTime, strikes)
%PRICEPARTYBCOUPONBLACK Price one Party B structured coupon.
%
%   [priceCorrected, priceUncorrected] = pricePartyBCouponBlack( ...
%       paymentDiscount, forwardRate, accrualFactor, resetTime, ...
%       spread, barrier, elseCoupon, volsAtResetTime, strikes)
%
%   prices one Party B structured coupon, excluding notional multiplication.
%
%   The coupon payoff is:
%
%       (L + spread) * 1_{L <= barrier}
%       + elseCoupon * 1_{L > barrier}
%
%   where L is the forward Euribor/Libor rate fixing at resetTime.
%
%   The payoff is priced through the equivalent decomposition:
%
%       L + spread
%       - (L - barrier)^+
%       - (barrier + spread - elseCoupon) * 1_{L > barrier}
%
%   The call term:
%
%       E[(L - barrier)^+]
%
%   is priced with Black-76 using the volatility interpolated at the
%   barrier strike.
%
%   The digital term:
%
%       P(L > barrier)
%
%   is computed in two ways:
%
%       priceUncorrected
%           Uses the standard Black-76 digital probability N(d2).
%
%       priceCorrected
%           Uses the smile-corrected digital probability:
%
%               N(d2) - F * sqrt(T) * n(d1) * dSigma/dK
%
%           where dSigma/dK is the local slope of the volatility smile at
%           the barrier.
%
%   INPUTS:
%       paymentDiscount
%           Discount factor P(0,T_payment).
%
%       forwardRate
%           Forward Euribor/Libor rate L(0;T_reset,T_payment), in decimal
%           units.
%
%       accrualFactor
%           Coupon accrual factor.
%
%       resetTime
%           Time to reset, in years.
%
%       spread
%           Coupon spread, in decimal units.
%
%       barrier
%           Coupon barrier, in decimal units.
%
%       elseCoupon
%           Coupon paid when L > barrier, in decimal units.
%
%       volsAtResetTime
%           Volatility smile at the coupon reset time, in decimal units.
%           One volatility for each strike.
%
%       strikes
%           Strike grid corresponding to volsAtResetTime, in decimal units.
%
%   OUTPUTS:
%       priceCorrected
%           Present value of the coupon using the smile-corrected digital
%           probability, excluding notional multiplication.
%
%       priceUncorrected
%           Present value of the coupon using the uncorrected Black-76
%           digital probability, excluding notional multiplication.
%
%   ASSUMPTIONS:
%       - All rates, strikes and volatilities are expressed in decimal
%         units.
%       - volsAtResetTime is aligned with strikes.
%       - Spline interpolation and extrapolation are used on the strike
%         dimension.
%       - If the Black formula is not well-defined, the call term is valued
%         by intrinsic value.
%       - The coupon is scalar: one payment date, one reset time, one
%         forward rate and one accrual factor.

    strikes = strikes(:);
    volsAtResetTime = volsAtResetTime(:);

    %% Digital probabilities

    [digitalProbCorrected, digitalProbUncorrected] = ...
        computeDigitalSmileCorrection( ...
            paymentDiscount, ...
            forwardRate, ...
            accrualFactor, ...
            resetTime, ...
            barrier, ...
            volsAtResetTime.', ...
            strikes);

    %% Black call part: E[(L - barrier)^+]

    sigmaBarrier = interp1( ...
        strikes, ...
        volsAtResetTime, ...
        barrier, ...
        'spline', ...
        'extrap');

    if resetTime > 0 && sigmaBarrier > 0 && forwardRate > 0 && barrier > 0

        stdDev = sigmaBarrier * sqrt(resetTime);

        d1 = ...
            (log(forwardRate / barrier) + 0.5 * stdDev^2) ...
            / stdDev;

        d2 = d1 - stdDev;

        callPart = ...
            forwardRate * normcdf(d1) ...
            - barrier * normcdf(d2);

    else

        callPart = max(forwardRate - barrier, 0.0);

    end

    %% Expected coupons

    digitalCoefficient = ...
        barrier + spread - elseCoupon;

    expectedCouponUncorrected = ...
        forwardRate ...
        + spread ...
        - callPart ...
        - digitalCoefficient * digitalProbUncorrected;

    expectedCouponCorrected = ...
        forwardRate ...
        + spread ...
        - callPart ...
        - digitalCoefficient * digitalProbCorrected;

    %% Present values, excluding notional

    discountAccrual = paymentDiscount * accrualFactor;

    priceUncorrected = ...
        discountAccrual * expectedCouponUncorrected;

    priceCorrected = ...
        discountAccrual * expectedCouponCorrected;

end