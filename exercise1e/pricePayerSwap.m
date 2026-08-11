function npv = pricePayerSwap(market, matYears, notional, swapRate)
%PRICEPAYERSWAP Valuta un payer swap ATM (annual, 30E/360)
%   Payer: paghi fisso ATM, ricevi floating
%   NPV = notional * ((1 - P(0,TN)) - swapRate * BPV)

    refDate   = market.dates(1);
    dates     = market.dates;
    discounts = market.discounts;

    getDF = @(d) getDiscountFactorByZeroRatesLinearInterp(...
                     refDate, d, dates, discounts);

    % Schedule annuale 30E/360 come nel bootstrap
    couponDates = datetime.empty(0,1);
    for k = 1:matYears
        couponDates(k) = refDate + calyears(k);
    end
    couponDates = couponDates(:);

    % Yearfrac 30E/360
    allDates  = [refDate; couponDates];
    taus      = yearfrac(allDates(1:end-1), allDates(2:end), 6);

    % Discount factors
    dfCoupons = arrayfun(getDF, couponDates);

    % BPV = sum(tau_i * P(0,Ti))
    BPV   = sum(taus .* dfCoupons);
    df_TN = dfCoupons(end);

    % ATM swap rate dalla curva corrente

    % Payer swap: ricevi floating - paghi fisso
    % float leg = 1 - P(0,TN)
    % fixed leg = swapRate * BPV
    npv = notional * ((1 - df_TN) - swapRate * BPV);

end


