function stats = buildExoticCapSpotStats( ...
    price, pathPV, couponPayoff, discountToPayment, discountedCoupon, ...
    bFixed, liborFixed, capletVols, dt, market, product, nPaths)
%BUILDEXOTICCAPSPOTSTATS Build stats struct for spot-measure diagnostics.
%
%   stats = buildExoticCapSpotStats(...)
%
%   builds the diagnostics struct consumed by the external diagnostic
%   functions for the spot-measure Monte Carlo exotic-cap pricer.

    nCoupons = ...
        size(couponPayoff, 2);

    standardError = ...
        std(pathPV) / sqrt(nPaths);

    paymentIdx = ...
        product.paymentIdx(:).';

    meanDiscountToPayment = ...
        reshape(mean(discountToPayment, 1), 1, []);

    marketDiscountToPayment = ...
        reshape(market.tenor.discounts(paymentIdx), 1, []);

    discountError = ...
        meanDiscountToPayment - marketDiscountToPayment;

    meanCouponPayoff = ...
        mean(couponPayoff, 1);

    meanDiscountedCoupon = ...
        mean(discountedCoupon, 1);

    contribution = ...
        product.principal * meanDiscountedCoupon;

    stats = struct();

    stats.nPaths = nPaths;
    stats.nCoupons = nCoupons;

    stats.price = price;
    stats.standardError = standardError;
    stats.confidenceInterval95 = ...
        price + 1.96 * standardError * [-1, 1];

    stats.pathPV = pathPV;

    stats.bFixed = bFixed;
    stats.Bfixed = bFixed;

    stats.liborFixed = liborFixed;
    stats.LiborFixed = liborFixed;

    stats.couponPayoff = couponPayoff;
    stats.discountToPayment = discountToPayment;

    stats.meanCouponPayoff = meanCouponPayoff;
    stats.meanDiscountedCoupon = meanDiscountedCoupon;
    stats.contribution = contribution;

    stats.meanDiscountToPayment = meanDiscountToPayment;
    stats.marketDiscountToPayment = marketDiscountToPayment;
    stats.discountError = discountError;

    stats.capletVols = capletVols;
    stats.vi = capletVols;

    stats.dt = dt;

end