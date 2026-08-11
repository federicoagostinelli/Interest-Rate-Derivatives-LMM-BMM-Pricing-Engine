function [price, stats] = priceExoticCapBmmSpotMonteCarlo( ...
    market, product, volsBMM, nPaths, seed)
%PRICEEXOTICCAPBMMSPOTMONTECARLO Price exotic cap under BMM spot measure.
%
%   [price, stats] = priceExoticCapBmmSpotMonteCarlo( ...
%       market, product, volsBMM, nPaths, seed)
%
%   prices the exotic cap by spot-measure Monte Carlo.
%
%   The coupon paid at T_p is:
%
%       principal * delta_q
%       * max( L_q(T_q) - L_m(T_m) - spread, 0 )
%
%   where:
%
%       m = product.previousStartIdx
%       q = product.currentStartIdx
%       p = product.paymentIdx
%
%   The Libor fixing is recovered from the simulated BMM forward ZCB:
%
%       L_i(T_i) = (1 / B_i(T_i) - 1) / delta_i
%
%   The spot-measure pathwise discount factor to T_p is:
%
%       D(0,T_p) = prod_{j=1}^{p-1} B_j(T_j)

    if nargin < 4 || isempty(nPaths)
        nPaths = 10000;
    end

    if nargin < 5
        seed = [];
    end

    %% Simulate BMM spot-measure fixings

    [bFixed, ~, capletVols, dt] = simulateBMMSpotMeasure( ...
        market, ...
        volsBMM, ...
        nPaths, ...
        seed);

    %% Libor fixings

    accrualFactors = ...
        market.tenor.delta(:).';

    liborFixed = ...
        (1.0 ./ bFixed - 1.0) ...
        ./ accrualFactors;

    %% Product indexing

    previousIdx = ...
        product.previousStartIdx(:).';

    currentIdx = ...
        product.currentStartIdx(:).';

    paymentIdx = ...
        product.paymentIdx(:).';

    deltaCurrent = ...
        product.deltaCurrent(:).';

    nCoupons = ...
        numel(paymentIdx);

    %% Coupon payoffs

    couponPayoff = zeros(nPaths, nCoupons);

    for couponIdx = 1:nCoupons

        previousRate = ...
            liborFixed(:, previousIdx(couponIdx));

        currentRate = ...
            liborFixed(:, currentIdx(couponIdx));

        couponPayoff(:, couponIdx) = ...
            deltaCurrent(couponIdx) ...
            .* max(currentRate - previousRate - product.spread, 0.0);

    end

    %% Spot-measure pathwise discount factors

    cumulativeDiscount = ...
        cumprod(bFixed, 2);

    discountToPayment = ...
        zeros(nPaths, nCoupons);

    for couponIdx = 1:nCoupons

        payIdx = ...
            paymentIdx(couponIdx);

        if payIdx <= 1

            discountToPayment(:, couponIdx) = 1.0;

        else

            discountToPayment(:, couponIdx) = ...
                cumulativeDiscount(:, payIdx - 1);

        end

    end

    %% Pathwise PV

    discountedCoupon = ...
        discountToPayment .* couponPayoff;

    pathPV = ...
        product.principal ...
        * sum(discountedCoupon, 2);

    price = ...
        mean(pathPV);

    %% Stats for external diagnostics

    stats = buildExoticCapSpotStats( ...
        price, ...
        pathPV, ...
        couponPayoff, ...
        discountToPayment, ...
        discountedCoupon, ...
        bFixed, ...
        liborFixed, ...
        capletVols, ...
        dt, ...
        market, ...
        product, ...
        nPaths);

end