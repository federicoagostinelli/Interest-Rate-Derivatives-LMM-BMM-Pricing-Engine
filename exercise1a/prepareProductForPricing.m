function pricedProduct = prepareProductForPricing(product, market)
%PREPAREPRODUCTFORPRICING Add market-dependent pricing inputs.
%
%   pricedProduct = prepareProductForPricing(product, market)
%
%   enriches the contractual product struct with the market-dependent
%   quantities required to price the Party B coupon leg.
%
%   The product is assumed to start on the market reference date and to pay
%   on the same quarterly schedule used by the market tenor grid. Therefore
%   reset dates and payment dates are obtained by slicing:
%
%       market.tenor.dates
%
%   For coupon i:
%
%       period start date = T_i
%       payment date      = T_{i+1}
%       accrual period    = [T_i, T_{i+1}]
%
%   Time quantities and accrual factors are taken from:
%
%       market.tenor.resetTimes
%       market.tenor.times
%       market.tenor.delta
%
%   Discount factors are interpolated from the original bootstrapped
%   discount curve:
%
%       market.dates
%       market.discounts
%
%   The forward rate for each coupon period is then computed as:
%
%       F_i = (P(0,T_i) / P(0,T_{i+1}) - 1) / delta_i
%
%   INPUTS:
%       product
%           Contractual product struct created by initializeProductExercise1.
%
%       market
%           Market struct created by initializeInterestRateMarket.
%
%   OUTPUT:
%       pricedProduct
%           Product struct enriched with the Party B pricing quantities:
%
%               product.partyB.periodStartDates
%               product.partyB.paymentDates
%               product.partyB.resetTimes
%               product.partyB.paymentTimes
%               product.partyB.delta
%               product.partyB.periodStartDiscounts
%               product.partyB.paymentDiscounts
%               product.partyB.forwardRates

    pricedProduct = product;

    partyB = pricedProduct.partyB;

    numberOfCoupons = ...
        product.maturityYears * partyB.paymentsPerYear;

    tenorIdx = 1:numberOfCoupons;

    %% Dates

    partyB.periodStartDates = market.tenor.dates(tenorIdx).';
    partyB.paymentDates = market.tenor.dates(tenorIdx + 1).';

    %% Times and accrual factors

    partyB.resetTimes = market.tenor.resetTimes(tenorIdx).';
    partyB.paymentTimes = market.tenor.times(tenorIdx + 1).';
    partyB.delta = market.tenor.delta(tenorIdx).';

    %% Discount factors

    partyB.periodStartDiscounts = getDiscountFactorByZeroRatesLinearInterp( ...
        market.dates(1), ...
        partyB.periodStartDates, ...
        market.dates, ...
        market.discounts);

    partyB.paymentDiscounts = getDiscountFactorByZeroRatesLinearInterp( ...
        market.dates(1), ...
        partyB.paymentDates, ...
        market.dates, ...
        market.discounts);

    partyB.periodStartDiscounts = partyB.periodStartDiscounts(:);
    partyB.paymentDiscounts = partyB.paymentDiscounts(:);

    %% Forward Euribor rates

    partyB.forwardRates = ...
        (partyB.periodStartDiscounts ./ partyB.paymentDiscounts - 1.0) ...
        ./ partyB.delta;

    %% Store

    pricedProduct.partyB = partyB;

end