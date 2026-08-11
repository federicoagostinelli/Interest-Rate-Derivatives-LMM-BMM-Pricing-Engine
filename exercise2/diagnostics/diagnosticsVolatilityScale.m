function diagnosticsVolatilityScale(vols, modelName)
%DIAGNOSTICSVOLATILITYSCALE Check calibrated volatility scale.

    if nargin < 2 || isempty(modelName)
        modelName = 'Model';
    end

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' %s volatility scale check\n', modelName);
    fprintf('============================================================\n');
    fprintf('Min vols : %.12f\n', min(vols(:)));
    fprintf('Max vols : %.12f\n', max(vols(:)));
    fprintf('Mean vols: %.12f\n', mean(vols(:)));
    fprintf('============================================================\n\n');

    if max(vols(:)) > 5.0
        warning(['Volatilities look too large. ', ...
            'They may be in percent units, e.g. 20 instead of 0.20.']);
    end

end