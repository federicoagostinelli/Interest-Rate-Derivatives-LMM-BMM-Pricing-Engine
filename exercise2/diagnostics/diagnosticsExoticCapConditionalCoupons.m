function diagnosticsExoticCapConditionalCoupons(stats)
%DIAGNOSTICSEXOTICCAPCONDITIONALCOUPONS Print conditional MC coupon contributions.

    fprintf('============================================================\n');
    fprintf(' Conditional MC coupon contributions\n');
    fprintf('============================================================\n');
    fprintf('%5s %8s %8s %18s %18s %18s\n', ...
        'Cpn', 'PrevIdx', 'CurrIdx', 'Mean K', 'Coupon Price', 'Coupon SE');

    for c = 1:stats.nCoupons

        fprintf('%5d %8d %8d %18.10f %18.10f %18.10f\n', ...
            c, ...
            stats.previousIdx(c), ...
            stats.currentIdx(c), ...
            stats.meanK(c), ...
            stats.couponPrice(c), ...
            stats.couponSE(c));

    end

    fprintf('============================================================\n\n');

end