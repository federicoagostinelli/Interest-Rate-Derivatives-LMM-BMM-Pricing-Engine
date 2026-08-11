function market = initializeInterestRateMarket(curveDates, curveDiscounts, curveZeroRates)
%INITIALIZEINTERESTRATEMARKET Initialize interest-rate market data.
%
%   market = INITIALIZEINTERESTRATEMARKET(curveDates, curveDiscounts,
%   curveZeroRates) returns a struct containing:
%
%       - bootstrapped discount curve data;
%       - date and day-count conventions;
%       - cap volatility surface;
%       - model-independent quarterly tenor grid;
%       - forward rates and forward zero-coupon bonds on that tenor grid;
%       - Brownian-motion correlation matrix for BMM/LMM simulations.
%
%   INPUT
%       curveDates
%           [1 x N] or [N x 1] vector of bootstrapped curve dates.
%           The first date is used as the market reference date t0.
%
%       curveDiscounts
%           [1 x N] or [N x 1] vector of discount factors P(t0,T_i)
%           associated with curveDates.
%
%       curveZeroRates
%           [1 x N] or [N x 1] vector of continuously compounded zero rates
%           associated with curveDates.
%
%   OUTPUT
%       market
%           Struct with fields:
%
%           market.dates
%               Bootstrapped curve dates.
%
%           market.discounts
%               Bootstrapped discount factors P(t0,T_i).
%
%           market.zeroRates
%               Bootstrapped zero rates associated with market.dates.
%
%           market.dateInfo
%               Date and day-count conventions:
%
%                   refDate
%                       Market reference date t0. Equal to curveDates(1).
%
%                   tradeDate
%                       Trade date. Set equal to refDate.
%
%                   maturityAdjust
%                       Business-day adjustment convention used for cap
%                       maturity dates.
%
%                   paymentAdjust
%                       Business-day adjustment convention used for tenor
%                       and payment dates.
%
%                   dayCount
%                       Accrual day-count convention for Libor/Euribor
%                       periods. MATLAB basis 2 = ACT/360.
%
%                   blackDayCount
%                       Day-count convention used for Black option times,
%                       reset times, BMM simulation times and cap
%                       maturities. MATLAB basis 3 = ACT/365.
%
%           market.rho
%               [nCaplets x nCaplets] Brownian-motion correlation matrix.
%               Entry market.rho(i,j) is the instantaneous correlation
%               between the Brownian shocks driving tenor periods i and j.
%
%               The matrix is built as:
%
%                   rho(i,j) = exp(-lambda * yearfrac(T_i,T_j,ACT/365))
%
%               with lambda = market.correlation.lambda. The absolute time
%               distance is used, so rho is symmetric and rho(i,i)=1.
%
%               Here T_i and T_j are the reset dates of the corresponding
%               tenor periods. In MATLAB indexing, period i is:
%
%                   [market.tenor.dates(i), market.tenor.dates(i+1)].
%
%           market.correlation
%               Correlation model parameters:
%
%                   lambda
%                       Exponential-decay parameter used in the BMM
%                       exercise. Here lambda = 0.1.
%
%                   dayCount
%                       Day-count convention used to measure distances in
%                       the correlation formula. Here ACT/365.
%
%           market.surface
%               Cap volatility surface data:
%
%                   refDate
%                       Surface reference date.
%
%                   strikes
%                       Cap/floor strikes in decimal units.
%
%                   maturityYears
%                       Quoted cap maturities in years.
%
%                   maturityDates
%                       Adjusted cap maturity dates.
%
%                   maturities
%                       Year fractions from refDate to maturityDates,
%                       computed using blackDayCount.
%
%                   vols
%                       Flat Black cap volatility matrix in decimal units.
%                       Rows correspond to cap maturities and columns to
%                       strikes.
%
%           market.tenor
%               Model-independent quarterly tenor grid used for caplet
%               calibration and BMM/LMM simulations:
%
%                   tenorMonths
%                       Length of each tenor period in months. Here equal
%                       to 3, consistent with Euribor 3M.
%
%                   paymentsPerYear
%                       Number of tenor periods per year. Equal to
%                       12 / tenorMonths = 4.
%
%                   dayCount
%                       Accrual day-count convention used to compute the
%                       year fractions delta_i between consecutive tenor
%                       dates. Here ACT/360.
%
%                   blackDayCount
%                       Day-count convention used to compute model times,
%                       reset times and option maturities. Here ACT/365.
%
%                   dates
%                       Quarterly tenor dates T_0,T_1,...,T_M starting
%                       from market.dateInfo.refDate and extending to the
%                       maximum cap-surface maturity.
%
%                   discounts
%                       Discount factors P(t0,T_i) on the tenor grid.
%
%                   times
%                       Year fractions from refDate to each tenor date:
%
%                           times(i) = yearfrac(t0,T_i,blackDayCount)
%
%                   dt
%                       Simulation time steps between consecutive tenor
%                       dates, using blackDayCount:
%
%                           dt(i) = yearfrac(T_i,T_{i+1},blackDayCount)
%
%                       These are used in BMM Monte Carlo Brownian
%                       evolution.
%
%                   delta
%                       Accrual factors for each tenor period, using
%                       dayCount:
%
%                           delta(i) = yearfrac(T_i,T_{i+1},dayCount)
%
%                       These are used to convert forward ZCBs into Libor
%                       rates and to compute coupon payoffs.
%
%                   resetTimes
%                       Reset times for each caplet period:
%
%                           resetTimes(i) = yearfrac(t0,T_i,blackDayCount)
%
%                   forwardRates
%                       Initial forward Libor/Euribor rates:
%
%                           L_i(t0) =
%                               (P(t0,T_i)/P(t0,T_{i+1}) - 1) / delta_i
%
%                   forwardZCB
%                       Initial forward zero-coupon bonds:
%
%                           B_i(t0) = P(t0,T_{i+1}) / P(t0,T_i)
%
%                       In BMM this is the modeled state variable:
%
%                           B_i(t) = P(t,T_{i+1}) / P(t,T_i).
%
%   Surface convention:
%
%       market.surface.vols(i,j)
%
%   where i is the cap maturity index and j is the strike index.
%
%   Tenor indexing convention:
%
%       market.tenor.dates contains T_0,T_1,...,T_M.
%
%       market.tenor.delta(i), market.tenor.dt(i),
%       market.tenor.forwardRates(i), market.tenor.forwardZCB(i), and
%       market.tenor.resetTimes(i) refer to the period:
%
%           [T_i, T_{i+1}]
%
%       in mathematical notation, with MATLAB index i corresponding to
%       dates(i) -> dates(i+1).

    %% Defensive date conversion

    if isnumeric(curveDates)
        curveDates = datetime(curveDates, 'ConvertFrom', 'datenum');
    end

    %% Market struct

    market = struct();

    market.dates = curveDates;
    market.discounts = curveDiscounts;
    market.zeroRates = curveZeroRates;

    %% Date information

    market.dateInfo = struct();

    market.dateInfo.refDate = curveDates(1);
    market.dateInfo.tradeDate = market.dateInfo.refDate;

    market.dateInfo.maturityAdjust = 'following';
    market.dateInfo.paymentAdjust = 'modifiedfollowing';

    market.dateInfo.dayCount = 2; % ACT/360
    market.dateInfo.blackDayCount = 3; % ACT/365

    %% Correlation model parameters

    market.correlation = struct();
    market.correlation.lambda = 0.1;
    market.correlation.dayCount = market.dateInfo.blackDayCount;

    %% Model-independent quarterly tenor grid

    market.tenor = struct();

    % Euribor 3M / quarterly tenor grid.
    market.tenor.tenorMonths = 3;
    market.tenor.paymentsPerYear = 12 / market.tenor.tenorMonths;

    market.tenor.dayCount = market.dateInfo.dayCount;
    market.tenor.blackDayCount = market.dateInfo.blackDayCount;

    %% Cap volatility surface

    market.surface = struct();

    market.surface.refDate = market.dateInfo.refDate;

    % Quoted cap/floor strikes are in percent in the source table.
    market.surface.strikes = [ ...
        1.50 1.75 2.00 2.25 2.50 3.00 3.50 ...
        4.00 5.00 6.00 7.00 8.00 10.00] / 100;

    market.surface.maturityYears = [ ...
        1 2 3 4 5 6 7 8 9 10 12 15 20];

    market.surface.maturityDates = arrayfun( ...
        @(y) businessDateOffsetTarget( ...
            market.surface.refDate, ...
            y, ...
            0, ...
            0, ...
            market.dateInfo.maturityAdjust), ...
        market.surface.maturityYears);

    market.surface.maturities = yearfrac( ...
        market.surface.refDate, ...
        market.surface.maturityDates, ...
        market.dateInfo.blackDayCount);

    % Flat Black cap volatilities.
    % Rows    = cap maturities
    % Columns = strikes
    market.surface.vols = [
        14.0 13.0 12.9 12.1 13.3 13.8 14.4 15.0 17.2 19.1 20.2 21.6 23.9
        22.4 19.7 17.5 18.0 19.2 20.4 21.0 21.4 22.3 23.6 24.9 26.1 28.1
        23.8 21.7 20.0 19.8 20.3 20.5 20.8 21.4 22.9 24.3 25.6 26.7 28.2
        24.2 22.4 20.9 20.4 20.4 20.2 20.2 20.5 21.7 22.9 24.0 25.0 26.6
        24.3 22.6 21.2 20.6 20.4 19.8 19.5 19.6 20.5 21.5 22.6 23.5 25.0
        24.3 22.7 21.4 20.7 20.2 19.4 18.9 18.8 19.3 20.2 21.2 22.0 23.5
        24.1 22.6 21.4 20.7 20.1 19.1 18.4 18.1 18.4 19.1 20.0 20.8 22.2
        23.9 22.5 21.4 20.6 20.0 18.8 18.0 17.6 17.6 18.2 19.0 19.8 21.1
        23.7 22.4 21.3 20.5 19.8 18.5 17.6 17.1 17.0 17.6 18.3 19.0 20.3
        23.5 22.2 21.2 20.4 19.6 18.3 17.3 16.8 16.5 16.9 17.6 18.3 19.5
        23.0 21.7 20.8 20.0 19.3 17.9 16.9 16.2 15.8 16.0 16.5 17.1 18.1
        22.3 21.2 20.3 19.5 18.7 17.3 16.3 15.5 15.0 15.1 15.5 16.0 16.9
        21.6 20.4 19.5 18.8 18.0 16.6 15.5 14.7 14.1 14.1 14.5 15.0 15.9
    ] / 100;

    %% Quarterly calibration tenor schedule

    maxMaturityYears = max(market.surface.maturityYears);
    nPeriods = maxMaturityYears * market.tenor.paymentsPerYear;

    market.tenor.dates = arrayfun( ...
        @(k) businessDateOffsetTarget( ...
            market.dateInfo.refDate, ...
            0, ...
            k * market.tenor.tenorMonths, ...
            0, ...
            market.dateInfo.paymentAdjust), ...
        0:nPeriods);

    market.tenor.discounts = arrayfun( ...
        @(d) getDiscountFactorByZeroRatesLinearInterp( ...
            market.dateInfo.refDate, ...
            d, ...
            market.dates, ...
            market.discounts), ...
        market.tenor.dates);

    market.tenor.times = yearfrac( ...
        market.dateInfo.refDate, ...
        market.tenor.dates, ...
        market.dateInfo.blackDayCount);

    % ACT/365 simulation time steps for Brownian evolution.
    market.tenor.dt = yearfrac( ...
        market.tenor.dates(1:end-1), ...
        market.tenor.dates(2:end), ...
        market.dateInfo.blackDayCount);

    % ACT/360 accrual factors for Libor/Euribor periods.
    market.tenor.delta = yearfrac( ...
        market.tenor.dates(1:end-1), ...
        market.tenor.dates(2:end), ...
        market.dateInfo.dayCount);

    market.tenor.resetTimes = yearfrac( ...
        market.dateInfo.refDate, ...
        market.tenor.dates(1:end-1), ...
        market.dateInfo.blackDayCount);

    market.tenor.forwardRates = ...
        (market.tenor.discounts(1:end-1) ./ market.tenor.discounts(2:end) - 1) ...
        ./ market.tenor.delta;

    market.tenor.forwardZCB = ...
        market.tenor.discounts(2:end) ./ market.tenor.discounts(1:end-1);

    %% Brownian-motion correlation matrix

    resetDates = market.tenor.dates(1:end-1);

    resetTimesForCorrelation = yearfrac( ...
        market.dateInfo.refDate, ...
        resetDates, ...
        market.correlation.dayCount);

    timeDistances = abs( ...
        resetTimesForCorrelation(:) ...
        - resetTimesForCorrelation(:).' );

    market.rho = exp( ...
        -market.correlation.lambda ...
        * timeDistances);
    end
