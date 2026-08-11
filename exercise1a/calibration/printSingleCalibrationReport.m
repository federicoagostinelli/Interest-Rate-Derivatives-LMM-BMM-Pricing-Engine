function printSingleCalibrationReport(report)
%PRINTSINGLECALIBRATIONREPORT Print one calibration diagnostics table.

    surface = report.surface;
    strikes = surface.strikes(:).';

    numberOfStrikes = numel(strikes);
    numberOfMaturities = numel(surface.maturities);

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('%s Calibration Report\n', report.modelType);
    fprintf('============================================================\n');
    fprintf('Number of strikes      : %d\n', numberOfStrikes);
    fprintf('Number of maturities   : %d\n', numberOfMaturities);
    fprintf('First fixed caplet     : excluded from volatility matrix\n');
    fprintf('Max absolute error     : %.6e\n', report.maxAbsError);
    fprintf('Max relative error     : %.6e\n', report.maxRelError);
    fprintf('RMSE                   : %.6e\n', report.rmse);
    fprintf('============================================================\n\n');

    fprintf('%8s %10s %15s %15s %15s %15s\n', ...
        'Mat', 'Strike', 'TargetPrice', 'ModelPrice', 'AbsError', 'RelError');

    fprintf('%8s %10s %15s %15s %15s %15s\n', ...
        '--------', '----------', '---------------', '---------------', ...
        '---------------', '---------------');

    for maturityIdx = 1:numberOfMaturities
        for strikeIdx = 1:numberOfStrikes

            fprintf('%8.2f %9.2f%% %15.8e %15.8e %15.8e %15.8e\n', ...
                surface.maturityYears(maturityIdx), ...
                100.0 * strikes(strikeIdx), ...
                report.marketPrices(maturityIdx, strikeIdx), ...
                report.modelPrices(maturityIdx, strikeIdx), ...
                report.absErrors(maturityIdx, strikeIdx), ...
                report.relErrors(maturityIdx, strikeIdx));

        end
    end

    fprintf('\n');

end