function capletPrices = computeBmmCapletPrice(paymentDiscounts, forwardRates, ...
                                              accrualFactors, resetTimes, ...
                                              volatilities, strike)
%COMPUTEBMMCAPLETPRICE Compute BMM caplet prices.
%
%   capletPrices = computeBmmCapletPrice(paymentDiscounts, forwardRates,
%   accrualFactors, resetTimes, volatilities, strike)
%
%   prices caplets under the BMM forward-ZCB representation.
%
%   BMM state variable:
%
%       B_i(t) = P(t,T_{i+1}) / P(t,T_i)
%
%   Libor relation:
%
%       L_i(t) = (1 / B_i(t) - 1) / delta_i
%
%   Caplet payoff paid at T_{i+1}:
%
%       delta_i * max(L_i(T_i) - K, 0)
%
%   Discounted to T_i this becomes:
%
%       max(1 - (1 + delta_i*K) * B_i(T_i), 0)
%
%   Therefore the caplet is a put option on B_i.
%
%   The BMM volatility input v_i is not the direct lognormal volatility of
%   B_i. The effective volatility of B_i is:
%
%       beta_i = (1 - B_i) * v_i
%
%   In this closed-form caplet approximation, beta_i is frozen at its
%   initial value:
%
%       beta_i(0) = (1 - B_i(0)) * v_i
%
%   INPUTS:
%       paymentDiscounts
%           Discount factors P(0,T_{i+1}).
%
%       forwardRates
%           Forward Libor rates F_i.
%
%       accrualFactors
%           Accrual factors delta_i.
%
%       resetTimes
%           Reset times T_i in ACT/365 years.
%
%       volatilities
%           BMM volatility inputs v_i.
%
%       strike
%           Libor strike K.
%
%   OUTPUT:
%       capletPrices
%           Caplet prices excluding notional multiplication.

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

    if isscalar(strike)
        strike = strike * ones(targetSize);
    end

    capletPrices = zeros(targetSize);

    %% Forward ZCB and start-date discount

    forwardBond = ...
        1.0 ./ (1.0 + accrualFactors .* forwardRates);

    startDiscounts = ...
        paymentDiscounts ./ forwardBond;

    strikeMultiplier = ...
        1.0 + accrualFactors .* strike;

    bondStrike = ...
        1.0 ./ strikeMultiplier;

    %% Effective BMM volatility of the forward ZCB

    effectiveBondVol = ...
        (1.0 - forwardBond) .* volatilities;

    idxBlack = ...
        resetTimes > 0 ...
        & effectiveBondVol > 0 ...
        & forwardBond > 0 ...
        & bondStrike > 0 ...
        & startDiscounts > 0;

    standardDeviation = ...
        effectiveBondVol(idxBlack) ...
        .* sqrt(resetTimes(idxBlack));

    d1 = ...
        (log(forwardBond(idxBlack) ./ bondStrike(idxBlack)) ...
        + 0.5 .* standardDeviation.^2) ...
        ./ standardDeviation;

    d2 = ...
        d1 - standardDeviation;

    putOnBond = ...
        bondStrike(idxBlack) .* normcdf(-d2) ...
        - forwardBond(idxBlack) .* normcdf(-d1);

    capletPrices(idxBlack) = ...
        startDiscounts(idxBlack) ...
        .* strikeMultiplier(idxBlack) ...
        .* putOnBond;

    %% Deterministic / expired case

    idxIntrinsic = ~idxBlack;

    capletPrices(idxIntrinsic) = ...
        startDiscounts(idxIntrinsic) ...
        .* max( ...
            1.0 ...
            - strikeMultiplier(idxIntrinsic) .* forwardBond(idxIntrinsic), ...
            0.0);

end