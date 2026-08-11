function diagnosticsExoticCapProduct(product)
%DIAGNOSTICSEXOTICCAPPRODUCT Print consistency checks for the exotic cap product.

    principal = product.principal;

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' Exotic cap product checks\n');
    fprintf('============================================================\n');

    fprintf('Principal       : %.12f\n', principal);
    fprintf('Spread          : %.12f\n', product.spread);
    fprintf('Min deltaCurrent: %.12f\n', min(product.deltaCurrent));
    fprintf('Max deltaCurrent: %.12f\n', max(product.deltaCurrent));
    fprintf('Mean deltaCurr  : %.12f\n', mean(product.deltaCurrent));
    fprintf('Number coupons  : %d\n', numel(product.paymentIdx));

    fprintf('First prev idx  : %d\n', product.previousStartIdx(1));
    fprintf('First curr idx  : %d\n', product.currentStartIdx(1));
    fprintf('First pay idx   : %d\n', product.paymentIdx(1));

    fprintf('Last prev idx   : %d\n', product.previousStartIdx(end));
    fprintf('Last curr idx   : %d\n', product.currentStartIdx(end));
    fprintf('Last pay idx    : %d\n', product.paymentIdx(end));

    fprintf('============================================================\n\n');

end