function diagnosticsExoticCapSpotState(price, stats, product)
%DIAGNOSTICSEXOTICCAPSPOTSTATE Print state-level diagnostics for spot MC.

    principal = product.principal;

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' Exotic cap MC state diagnostics\n');
    fprintf('============================================================\n');

    fprintf('Price                : %.12f\n', price);
    fprintf('Principal            : %.12f\n', principal);

    fprintf('Min Bfixed           : %.12f\n', min(stats.Bfixed(:)));
    fprintf('Max Bfixed           : %.12f\n', max(stats.Bfixed(:)));
    fprintf('Mean Bfixed          : %.12f\n', mean(stats.Bfixed(:)));

    fprintf('Min LiborFixed       : %.12f\n', min(stats.LiborFixed(:)));
    fprintf('Max LiborFixed       : %.12f\n', max(stats.LiborFixed(:)));
    fprintf('Mean LiborFixed      : %.12f\n', mean(stats.LiborFixed(:)));

    fprintf('Min couponPayoff     : %.12f\n', min(stats.couponPayoff(:)));
    fprintf('Max couponPayoff     : %.12f\n', max(stats.couponPayoff(:)));
    fprintf('Mean couponPayoff    : %.12f\n', mean(stats.couponPayoff(:)));

    fprintf('Min discountToPayment: %.12f\n', min(stats.discountToPayment(:)));
    fprintf('Max discountToPayment: %.12f\n', max(stats.discountToPayment(:)));
    fprintf('Mean discountToPay   : %.12f\n', mean(stats.discountToPayment(:)));

    fprintf('Mean pathPV          : %.12f\n', mean(stats.pathPV));
    fprintf('Max pathPV           : %.12f\n', max(stats.pathPV));

    fprintf('============================================================\n\n');

end