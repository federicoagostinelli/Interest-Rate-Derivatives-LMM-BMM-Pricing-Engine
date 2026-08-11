function productShocked = reshockProduct(productBase, marketShocked)

    productShocked = productBase;
    
    refDate   = marketShocked.dates(1);
    dates     = marketShocked.dates;
    discounts = marketShocked.discounts;

    pb = productBase.partyB;

    nPay = numel(pb.paymentDates);
    dfReset   = zeros(size(pb.resetDiscounts));    % ← stesso shape dell'originale
    dfPayment = zeros(size(pb.paymentDiscounts));  % ← stesso shape dell'originale

    for k = 1:nPay
        dfReset(k)   = getDiscountFactorByZeroRatesLinearInterp( ...
                            refDate, pb.resetDates(k), dates, discounts);
        dfPayment(k) = getDiscountFactorByZeroRatesLinearInterp( ...
                            refDate, pb.paymentDates(k), dates, discounts);
    end

    productShocked.partyB.resetDiscounts   = dfReset;
    productShocked.partyB.paymentDiscounts = dfPayment;

    % Mantieni stesso shape anche per forwardRates
    delta = pb.delta;  % NON fare (:), mantieni shape originale
    productShocked.partyB.forwardRates = (dfReset ./ dfPayment - 1) ./ delta;

end