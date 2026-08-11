function capletPrices = computeCapletPriceBlack( ...
    paymentDiscounts, forwardRates, accrualFactors, resetTimes, ...
    volatilities, strikes)
%COMPUTECAPLETPRICEBLACK Compute Black-76 caplet prices.
%
%   capletPrices = computeCapletPriceBlack( ...
%       paymentDiscounts, forwardRates, accrualFactors, resetTimes, ...
%       volatilities, strikes)
%
%   returns Black-76 caplet prices, excluding notional multiplication:
%
%       P(0,T_pay) * delta * E[(L(T_reset) - K)^+]
%
%   ASSUMPTIONS:
%       - forwardRates defines the output size.
%       - Non-scalar inputs have the same size as forwardRates.
%       - Scalar inputs are expanded to the size of forwardRates.
%       - Inputs are finite numeric values.
%       - paymentDiscounts are discount factors.
%       - accrualFactors are accrual factors.
%       - resetTimes are option expiries in years.
%       - volatilities are Black volatilities in decimal units.
%       - forwardRates and strikes are expressed in decimal units.
%
%   The Black formula is used only where:
%
%       resetTime  > 0
%       volatility > 0
%       forward    > 0
%       strike     > 0
%
%   Elsewhere, including trial negative volatilities generated during root
%   search, the deterministic intrinsic value is used:
%
%       P(0,T_pay) * delta * max(forward - strike, 0)
%
%   OUTPUT:
%       capletPrices
%           Black-76 caplet prices, excluding notional multiplication, with
%           the same size as forwardRates.

    targetSize = size(forwardRates);

    if isscalar(paymentDiscounts)
        paymentDiscounts = paymentDiscounts * ones(targetSize);
    end

    if isscalar(accrualFactors)
        accrualFactors = accrualFactors * ones(targetSize);
    end

    if isscalar(resetTimes)
        resetTimes = resetTimes * ones(targetSize);
    end

    if isscalar(volatilities)
        volatilities = volatilities * ones(targetSize);
    end

    if isscalar(strikes)
        strikes = strikes * ones(targetSize);
    end

    capletPrices = zeros(targetSize);

    idxBlack = resetTimes > 0 & ...
               volatilities > 0 & ...
               forwardRates > 0 & ...
               strikes > 0;

    standardDeviations = volatilities(idxBlack) .* sqrt(resetTimes(idxBlack));

    d1 = (log(forwardRates(idxBlack) ./ strikes(idxBlack)) + ...
        0.5 .* standardDeviations.^2) ./ standardDeviations;

    d2 = d1 - standardDeviations;

    capletPrices(idxBlack) = ...
        paymentDiscounts(idxBlack) .* accrualFactors(idxBlack) .* ...
        (forwardRates(idxBlack) .* normcdf(d1) - ...
         strikes(idxBlack) .* normcdf(d2));

    idxIntrinsic = ~idxBlack;

    capletPrices(idxIntrinsic) = ...
        paymentDiscounts(idxIntrinsic) .* accrualFactors(idxIntrinsic) .* ...
        max(forwardRates(idxIntrinsic) - strikes(idxIntrinsic), 0);

end