function product = initializeExoticCapProduct(market)
%INITIALIZEEXOTICCAPPRODUCT Initialize the exotic cap product.
%
%   product = initializeExoticCapProduct(market)
%
%   builds the contractual data of the exotic cap. The product start date is
%   set equal to the market reference date.
%
%   This function stores only contractual inputs. Market-dependent pricing
%   quantities such as payment dates, reset times, accrual factors,
%   discount factors, forward rates and tenor-grid indices are added later
%   by:
%
%       product = prepareExoticCapForPricing(product, market);
%
%   INPUT:
%       market
%           Market struct created by initializeInterestRateMarket.
%
%   OUTPUT:
%       product
%           Product struct containing contractual data only.

    product = struct();

    %% General contractual data

    product.principal = 1.0;
    product.currency = 'EUR';

    product.startDate = market.dateInfo.refDate;
    product.maturityYears = 4;
    product.endDate = product.startDate + calyears(product.maturityYears);

    %% Tenor and conventions

    product.tenorMonths = 3;
    product.paymentsPerYear = 12 / product.tenorMonths;

    product.firstPaymentMonths = 6;

    product.paymentAdjust = 'modifiedfollowing';
    product.maturityAdjust = 'following';

    product.dayCount = market.dateInfo.dayCount;             % ACT/360
    product.blackDayCount = market.dateInfo.blackDayCount;   % ACT/365

    %% Payoff parameter

    product.spread = 5.0e-4;    % 5 bps

end