function product = initializeProductExercise1(market)
%INITIALIZEPRODUCTEXERCISE1 Initialize the structured bond product.
%
%   product = initializeProductExercise1(market)
%
%   builds the contractual data of the structured bond. The product start
%   date is set equal to the market reference date.
%
%   This function stores only contractual inputs. Market-dependent pricing
%   quantities such as payment dates, reset times, accrual factors,
%   discount factors and forward rates are added later by:
%
%       product = prepareProductForPricing(product, market);
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

    product.principal = 5.0e7;
    product.currency = 'EUR';

    product.startDate = market.dateInfo.refDate;
    product.maturityYears = 10;
    product.endDate = product.startDate + calyears(product.maturityYears);

    %% Conventions

    product.paymentAdjust = 'modifiedfollowing';
    product.maturityAdjust = 'modifiedfollowing';

    product.dayCount = market.dateInfo.dayCount;             % ACT/360
    product.blackDayCount = market.dateInfo.blackDayCount;   % ACT/365

    %% Party A contractual data

    product.partyA = struct();

    product.partyA.spread = 0.0200;
    product.partyA.paymentsPerYear = 4;

    %% Party B contractual data

    product.partyB = struct();

    product.partyB.paymentsPerYear = 4;
    product.partyB.firstCoupon = 0.0400;

    %% Party B coupon rules
    %
    % Format:
    %
    %   [startYear, endYear, spread, barrier, elseCoupon]
    %
    % All rates are expressed in decimal units.

    product.rules = [
        0.0,  3.0,  0.010,  0.042,  0.045
        3.0,  6.0,  0.012,  0.047,  0.049
        6.0, 10.0,  0.013,  0.054,  0.056
    ];

end