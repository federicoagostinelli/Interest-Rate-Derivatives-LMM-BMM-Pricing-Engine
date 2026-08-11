function productMkt = prepareExoticCapForPricing(product, market)
%PREPAREEXOTICCAPFORPRICING Add market-dependent pricing inputs to exotic cap.
%
%   productMkt = prepareExoticCapForPricing(product, market)
%
%   enriches the contractual exotic cap product with the market-dependent
%   quantities required for BMM pricing.
%
%   The product is assumed to start on the market reference date and to use
%   the same quarterly schedule as market.tenor.dates. Therefore all coupon
%   dates are obtained by slicing:
%
%       market.tenor.dates
%
%   The contractual payoff starts at the first payment date 6 months after
%   start date. With a quarterly tenor grid:
%
%       T_0, T_1, ..., T_16
%
%   the payment dates are:
%
%       T_2, T_3, ..., T_16
%
%   For a payment at T_j, j = 2,...,16, the payoff is:
%
%       delta(T_{j-1}, T_j)
%       * max( L(T_{j-1}, T_j) - L(T_{j-2}, T_{j-1}) - spread, 0 )
%
%   Therefore each coupon requires:
%
%       previous period = [T_{j-2}, T_{j-1}]
%       current period  = [T_{j-1}, T_j]
%
%   Time quantities and accrual factors are taken from:
%
%       market.tenor.resetTimes
%       market.tenor.times
%       market.tenor.delta
%
%   Discount factors are interpolated from the original bootstrapped curve:
%
%       market.dates
%       market.discounts
%
%   Forward rates are then computed from interpolated discount factors.
%
%   INPUTS:
%       product
%           Contractual exotic cap struct created by initializeExoticCapProduct.
%
%       market
%           Market struct created by initializeInterestRateMarket.
%
%   OUTPUT:
%       productMkt
%           Product struct enriched with:
%
%               dates
%               paymentIdx
%               paymentDates
%               currentStartIdx
%               currentEndIdx
%               previousStartIdx
%               previousEndIdx
%               currentStartDates
%               currentEndDates
%               previousStartDates
%               previousEndDates
%               previousResetTimes
%               currentResetTimes
%               paymentTimes
%               deltaPrevious
%               deltaCurrent
%               previousStartDiscounts
%               previousEndDiscounts
%               currentStartDiscounts
%               currentEndDiscounts
%               paymentDiscounts
%               previousForwardRates
%               currentForwardRates
%               previousForwardZCB
%               currentForwardZCB
%               initialRandomStrike
%               initialZcbPutStrike

    productMkt = product;

    %% Tenor-grid indexing

    numberOfPeriods = ...
        product.maturityYears * product.paymentsPerYear;

    tenorDateIdx = 1:(numberOfPeriods + 1);

    productMkt.dates = market.tenor.dates(tenorDateIdx).';

    productMkt.endDate = productMkt.dates(end);

    firstPaymentIdx = ...
        product.firstPaymentMonths / product.tenorMonths + 1;

    productMkt.paymentIdx = ...
        firstPaymentIdx:numel(productMkt.dates);

    productMkt.paymentDates = ...
        productMkt.dates(productMkt.paymentIdx);

    productMkt.currentStartIdx = ...
        productMkt.paymentIdx - 1;

    productMkt.currentEndIdx = ...
        productMkt.paymentIdx;

    productMkt.previousStartIdx = ...
        productMkt.paymentIdx - 2;

    productMkt.previousEndIdx = ...
        productMkt.paymentIdx - 1;

    %% Coupon period dates

    productMkt.currentStartDates = ...
        productMkt.dates(productMkt.currentStartIdx);

    productMkt.currentEndDates = ...
        productMkt.dates(productMkt.currentEndIdx);

    productMkt.previousStartDates = ...
        productMkt.dates(productMkt.previousStartIdx);

    productMkt.previousEndDates = ...
        productMkt.dates(productMkt.previousEndIdx);

    %% Times and accrual factors

    productMkt.previousResetTimes = ...
        market.tenor.resetTimes(productMkt.previousStartIdx).';

    productMkt.currentResetTimes = ...
        market.tenor.resetTimes(productMkt.currentStartIdx).';

    productMkt.paymentTimes = ...
        market.tenor.times(productMkt.paymentIdx).';

    productMkt.deltaPrevious = ...
        market.tenor.delta(productMkt.previousStartIdx).';

    productMkt.deltaCurrent = ...
        market.tenor.delta(productMkt.currentStartIdx).';

    %% Discount factors

    productMkt.previousStartDiscounts = getDiscountFactorByZeroRatesLinearInterp( ...
        market.dateInfo.refDate, ...
        productMkt.previousStartDates, ...
        market.dates, ...
        market.discounts);

    productMkt.previousEndDiscounts = getDiscountFactorByZeroRatesLinearInterp( ...
        market.dateInfo.refDate, ...
        productMkt.previousEndDates, ...
        market.dates, ...
        market.discounts);

    productMkt.currentStartDiscounts = getDiscountFactorByZeroRatesLinearInterp( ...
        market.dateInfo.refDate, ...
        productMkt.currentStartDates, ...
        market.dates, ...
        market.discounts);

    productMkt.currentEndDiscounts = getDiscountFactorByZeroRatesLinearInterp( ...
        market.dateInfo.refDate, ...
        productMkt.currentEndDates, ...
        market.dates, ...
        market.discounts);

    productMkt.paymentDiscounts = getDiscountFactorByZeroRatesLinearInterp( ...
        market.dateInfo.refDate, ...
        productMkt.paymentDates, ...
        market.dates, ...
        market.discounts);

    productMkt.previousStartDiscounts = productMkt.previousStartDiscounts(:);
    productMkt.previousEndDiscounts = productMkt.previousEndDiscounts(:);
    productMkt.currentStartDiscounts = productMkt.currentStartDiscounts(:);
    productMkt.currentEndDiscounts = productMkt.currentEndDiscounts(:);
    productMkt.paymentDiscounts = productMkt.paymentDiscounts(:);

    %% Forward Libor rates

    productMkt.previousForwardRates = ...
        (productMkt.previousStartDiscounts ./ productMkt.previousEndDiscounts - 1.0) ...
        ./ productMkt.deltaPrevious;

    productMkt.currentForwardRates = ...
        (productMkt.currentStartDiscounts ./ productMkt.currentEndDiscounts - 1.0) ...
        ./ productMkt.deltaCurrent;

    %% Forward zero-coupon bonds

    productMkt.previousForwardZCB = ...
        productMkt.previousEndDiscounts ...
        ./ productMkt.previousStartDiscounts;

    productMkt.currentForwardZCB = ...
        productMkt.currentEndDiscounts ...
        ./ productMkt.currentStartDiscounts;

    %% Initial random-strike proxies

    productMkt.initialRandomStrike = ...
        productMkt.previousForwardRates ...
        + product.spread;

    productMkt.initialZcbPutStrike = ...
        1.0 ./ (1.0 ...
        + productMkt.deltaCurrent .* productMkt.initialRandomStrike);

end