function diagnosticsExoticCapConditionalMC(price, stats)
%DIAGNOSTICSEXOTICCAPCONDITIONALMC Print headline conditional MC results.

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' Exercise 2 - Exotic Cap BMM Conditional Monte Carlo\n');
    fprintf('============================================================\n');
    fprintf('Number of coupons : %d\n', stats.nCoupons);
    fprintf('Number of paths   : %d\n', stats.nPaths);
    fprintf('Price             : %.6f EUR\n', price);
    fprintf('Std error         : %.6f EUR\n', stats.standardError);
    fprintf('95%% CI            : [%.6f, %.6f] EUR\n', ...
        stats.confidenceInterval95(1), ...
        stats.confidenceInterval95(2));
    fprintf('============================================================\n\n');

end