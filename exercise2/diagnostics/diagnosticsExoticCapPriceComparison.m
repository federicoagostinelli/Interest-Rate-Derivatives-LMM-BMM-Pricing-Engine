function diagnosticsExoticCapPriceComparison(priceSpot, statsSpot, priceCond, statsCond)
%DIAGNOSTICSEXOTICCAPPRICECOMPARISON Compare spot-measure MC and conditional MC.

    diffPrice = priceSpot - priceCond;

    fprintf('============================================================\n');
    fprintf(' Exotic cap BMM price comparison\n');
    fprintf('============================================================\n');
    fprintf('Spot-measure MC price       : %.12f EUR\n', priceSpot);
    fprintf('Conditional MC price        : %.12f EUR\n', priceCond);
    fprintf('Difference Spot - Cond      : %.12f EUR\n', diffPrice);
    fprintf('Spot MC standard error      : %.12f EUR\n', statsSpot.standardError);
    fprintf('Conditional standard error  : %.12f EUR\n', statsCond.standardError);
    fprintf('Difference / Spot SE        : %.6f\n', ...
        diffPrice / statsSpot.standardError);
    fprintf('============================================================\n\n');

end