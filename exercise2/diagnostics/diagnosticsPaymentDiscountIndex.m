function diagnosticsPaymentDiscountIndex(market, product)
%DIAGNOSTICSPAYMENTDISCOUNTINDEX Compare product payment discounts with tenor-grid discounts.
%
% product.paymentDiscounts are discounts to actual product payment dates.
% BMM Monte Carlo discounts live on the model tenor grid.
% Therefore martingale checks must use market.tenor.discounts(paymentIdx).

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' Payment discount index check\n');
    fprintf('============================================================\n');
    fprintf('%5s %14s %14s %6s %18s %18s %18s\n', ...
        'Cpn', 'ProdPayDate', 'TenorDate', 'pIdx', ...
        'ProdDisc', 'TenorDisc', 'Diff');
    fprintf('%5s %14s %14s %6s %18s %18s %18s\n', ...
        '---', '-----------', '---------', '----', ...
        '--------', '---------', '----');

    for c = 1:numel(product.paymentIdx)

        p = product.paymentIdx(c);

        prodDisc = product.paymentDiscounts(c);
        tenorDisc = market.tenor.discounts(p);

        fprintf('%5d %14s %14s %6d %18.12f %18.12f %18.12f\n', ...
            c, ...
            datestr(product.paymentDates(c)), ...
            datestr(market.tenor.dates(p)), ...
            p, ...
            prodDisc, ...
            tenorDisc, ...
            prodDisc - tenorDisc);

    end

    fprintf('============================================================\n\n');

end