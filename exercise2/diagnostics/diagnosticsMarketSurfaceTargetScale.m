function diagnosticsMarketSurfaceTargetScale(market)
%DIAGNOSTICSMARKETSURFACETARGETSCALE Check explicit market target price scale.
%
%   diagnosticsMarketSurfaceTargetScale(market)
%
%   prints summary diagnostics for explicit target prices stored in
%   market.surface, if present.
%
%   The function does not throw warnings. Potential issues are printed as
%   diagnostic notes.

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' Market surface target price scale check\n');
    fprintf('============================================================\n');

    if isfield(market.surface, 'prices')

        targetPrices = market.surface.prices;
        targetFieldName = 'market.surface.prices';

    elseif isfield(market.surface, 'capletPrices')

        targetPrices = market.surface.capletPrices;
        targetFieldName = 'market.surface.capletPrices';

    elseif isfield(market.surface, 'targetPrices')

        targetPrices = market.surface.targetPrices;
        targetFieldName = 'market.surface.targetPrices';

    else

        targetPrices = [];
        targetFieldName = '';

        fprintf('Target price field       : not found\n');
        fprintf('Diagnostic note          : no explicit target price field found in market.surface.\n');

    end

    if ~isempty(targetPrices)

        fprintf('Target price field       : %s\n', targetFieldName);
        fprintf('Min target price         : %.12e\n', min(targetPrices(:)));
        fprintf('Max target price         : %.12e\n', max(targetPrices(:)));
        fprintf('Mean target price        : %.12e\n', mean(targetPrices(:)));

        if max(targetPrices(:)) > 1.0

            fprintf('Diagnostic note          : target prices larger than 1 for notional 1.\n');
            fprintf('Suggested checks         : notional scaling, cap vs caplet aggregation, or BMM formula units.\n');

        else

            fprintf('Diagnostic note          : target price scale looks compatible with unit notional.\n');

        end

    end

    fprintf('============================================================\n\n');

end