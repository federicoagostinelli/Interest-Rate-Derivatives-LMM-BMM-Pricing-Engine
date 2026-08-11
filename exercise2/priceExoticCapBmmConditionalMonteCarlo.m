function [price, stats] = priceExoticCapBmmConditionalMonteCarlo( ...
    market, product, volsBMM, nPaths, seed)
%PRICEEXOTICCAPBMMCONDITIONALMONTECARLO Price exotic cap by conditional MC.
%
%   [price, stats] = priceExoticCapBmmConditionalMonteCarlo( ...
%       market, product, volsBMM, nPaths, seed)
%
%   prices each coupon by simulating up to the previous reset date and then
%   applying a conditional BMM caplet formula for the current Libor.
%
%   For coupon c:
%
%       m = product.previousStartIdx(c)
%       q = product.currentStartIdx(c)
%
%   The random strike is:
%
%       K_c = L_m(T_m) + spread
%
%   Conditional on information at T_m, the current-rate option is valued as
%   a BMM caplet on L_q with strike K_c.

    if nargin < 4 || isempty(nPaths)
        nPaths = 10000;
    end

    if nargin < 5
        seed = [];
    end

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

    couponPathPrice = ...
        zeros(nPaths, nCoupons);

    randomStrike = ...
        zeros(nPaths, nCoupons);

    couponPrice = ...
        zeros(1, nCoupons);

    couponSE = ...
        zeros(1, nCoupons);

    for couponIdx = 1:nCoupons

        previousStartIdx = ...
            previousIdx(couponIdx);

        currentStartIdx = ...
            currentIdx(couponIdx);

        [bAtPreviousReset, stateIdx, capletVols, ~] = ...
            simulateBMMForwardMeasure( ...
                market, ...
                volsBMM, ...
                previousStartIdx, ...
                currentStartIdx, ...
                nPaths, ...
                seed + couponIdx - 1);

        previousStatePos = ...
            find(stateIdx == previousStartIdx, 1);

        currentStatePos = ...
            find(stateIdx == currentStartIdx, 1);

        bPrevious = ...
            bAtPreviousReset(:, previousStatePos);

        bCurrent = ...
            bAtPreviousReset(:, currentStatePos);

        previousRate = ...
            (1.0 ./ bPrevious - 1.0) ...
            ./ market.tenor.delta(previousStartIdx);

        currentForwardRate = ...
            (1.0 ./ bCurrent - 1.0) ...
            ./ market.tenor.delta(currentStartIdx);

        randomStrike(:, couponIdx) = ...
            previousRate + product.spread;

        paymentDiscountAtPreviousReset = ...
            bPrevious .* bCurrent;

        resetTimeFromPreviousToCurrent = ...
            market.tenor.times(currentStartIdx) ...
            - market.tenor.times(previousStartIdx);

        conditionalCouponValueAtPreviousReset = computeBmmCapletPrice( ...
            paymentDiscountAtPreviousReset, ...
            currentForwardRate, ...
            deltaCurrent(couponIdx), ...
            resetTimeFromPreviousToCurrent, ...
            capletVols(currentStartIdx), ...
            randomStrike(:, couponIdx));

        previousResetDiscount = ...
            market.tenor.discounts(previousStartIdx);

        couponPathPrice(:, couponIdx) = ...
            product.principal ...
            * previousResetDiscount ...
            * conditionalCouponValueAtPreviousReset;

        couponPrice(couponIdx) = ...
            mean(couponPathPrice(:, couponIdx));

        couponSE(couponIdx) = ...
            std(couponPathPrice(:, couponIdx)) / sqrt(nPaths);

    end

    pathPV = ...
        sum(couponPathPrice, 2);

    price = ...
        mean(pathPV);

    standardError = ...
        std(pathPV) / sqrt(nPaths);

    %% Stats for external diagnostics

    stats = struct();

    stats.nPaths = nPaths;
    stats.nCoupons = nCoupons;

    stats.price = price;
    stats.standardError = standardError;
    stats.confidenceInterval95 = ...
        price + 1.96 * standardError * [-1, 1];

    stats.pathPV = pathPV;

    stats.previousIdx = previousIdx;
    stats.currentIdx = currentIdx;
    stats.paymentIdx = paymentIdx;

    stats.randomStrike = randomStrike;
    stats.meanK = mean(randomStrike, 1);

    stats.couponPathPrice = couponPathPrice;
    stats.couponPrice = couponPrice;
    stats.couponSE = couponSE;

end