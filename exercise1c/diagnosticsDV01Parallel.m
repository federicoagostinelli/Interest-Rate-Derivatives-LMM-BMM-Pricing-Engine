function diagnosticsDV01Parallel(results, resultsZeroUpfront, resultsFairUpfront)
%DIAGNOSTICSDV01PARALLEL Print and plot diagnostics for parallel DV01.
%
%   DIAGNOSTICSDV01PARALLEL(results) prints a report and plots relevant
%   DV01 quantities.
%
%   DIAGNOSTICSDV01PARALLEL(results, resultsZeroUpfront, resultsFairUpfront)
%   also checks whether the DV01 depends on the upfront. The check compares
%   a DV01 computed with upfront = 0 and a DV01 computed with the fair
%   upfront.
%
%   INPUT
%       results
%           Output struct from computeDV01Parallel.
%
%       resultsZeroUpfront
%           Output struct from computeDV01Parallel computed with upfront = 0.
%
%       resultsFairUpfront
%           Output struct from computeDV01Parallel computed with fair
%           upfront.
%
%   The upfront dependency check prints only whether the DV01 depends on
%   upfront or not.

    %% Print main report

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' Parallel DV01 Diagnostics\n');
    fprintf('============================================================\n');
    fprintf('Upfront used            : %.8f %%\n', 100 * results.upfront);
    fprintf('Upfront amount          : %.2f EUR\n', results.upfrontAmount);
    fprintf('------------------------------------------------------------\n');
    fprintf('Base MtM                : %.6f EUR\n', results.mtmBase);
    fprintf('Partial shocked MtM     : %.6f EUR\n', results.partialMtmUp);
    fprintf('Total shocked MtM       : %.6f EUR\n', results.totalMtmUp);
    fprintf('------------------------------------------------------------\n');
    fprintf('Partial DV01            : %.6f EUR / bp\n', results.partialDV01);
    fprintf('Total DV01              : %.6f EUR / bp\n', results.totalDV01);
    fprintf('Total - Partial         : %.6f EUR / bp\n', results.diff);
    fprintf('------------------------------------------------------------\n');

    if isfield(results, 'maxAbsVolDiff')
        fprintf('Max abs LMM vol diff    : %.6e\n', results.maxAbsVolDiff);
    end

    fprintf('============================================================\n\n');

    %% Check upfront dependency, if both scenarios are provided

    if nargin >= 3 && ~isempty(resultsZeroUpfront) && ~isempty(resultsFairUpfront)

        tol = 1e-8;

        dPartial = abs(resultsZeroUpfront.partialDV01 - resultsFairUpfront.partialDV01);
        dTotal   = abs(resultsZeroUpfront.totalDV01   - resultsFairUpfront.totalDV01);

        if dPartial < tol && dTotal < tol
            fprintf('DV01 does NOT depend on upfront.\n\n');
        else
            fprintf('DV01 depends on upfront.\n\n');
        end

    end

    %% Plot DV01 quantities

    figure;

    bar([results.partialDV01, results.totalDV01, results.diff]);

    grid on;
    box on;

    set(gca, ...
        'XTick', 1:3, ...
        'XTickLabel', {'Partial DV01', 'Total DV01', 'Total - Partial'});

    ylabel('EUR / bp');
    title('Parallel DV01 Comparison');

    %% Plot MtM quantities

    figure;

    bar([results.mtmBase, results.partialMtmUp, results.totalMtmUp]);

    grid on;
    box on;

    set(gca, ...
        'XTick', 1:3, ...
        'XTickLabel', {'Base MtM', 'Partial shocked MtM', 'Total shocked MtM'});

    ylabel('EUR');
    title('MtM Comparison');

    %% Plot LMM vol recalibration difference, if available

    if isfield(results, 'volDiff') && ...
       isfield(results, 'marketUp') && ...
       isfield(results.marketUp, 'lmm') && ...
       isfield(results.marketUp, 'surface')

        market = results.marketUp;

        resetTimes = yearfrac( ...
            market.lmm.dates(1), ...
            market.lmm.dates(1:end-1), ...
            market.dateInfo.blackDayCount);

        [KGrid, TGrid] = meshgrid( ...
            market.surface.strikes, ...
            resetTimes);

        figure;

        surf(KGrid * 100, TGrid, results.volDiff * 10000);

        shading interp;
        grid on;
        box on;
        colorbar;

        xlabel('Strike (%)');
        ylabel('Reset time');
        zlabel('Vol difference (bp)');

        title('LMM Spot Vol Difference: Shocked Recalibration - Base');

        view(45, 30);

    end

end