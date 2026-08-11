function diagnosticsDV01Bucket(resultsFair, resultsZero)
%DIAGNOSTICSDV01BUCKET Diagnostics for bucket DV01 upfront cancellation.

    diffPartial = resultsFair.partialDV01 - resultsZero.partialDV01;
    diffTotal   = resultsFair.totalDV01   - resultsZero.totalDV01;

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('Bucket DV01 Upfront-Cancellation Diagnostics\n');
    fprintf('============================================================\n');
    fprintf('Max abs partial difference : %.6e EUR / bp\n', max(abs(diffPartial)));
    fprintf('Max abs total difference   : %.6e EUR / bp\n', max(abs(diffTotal)));
    fprintf('------------------------------------------------------------\n');
    fprintf('Fair upfront partial sum   : %.6f EUR / bp\n', resultsFair.sumPartialDV01);
    fprintf('Zero upfront partial sum   : %.6f EUR / bp\n', resultsZero.sumPartialDV01);
    fprintf('Fair upfront total sum     : %.6f EUR / bp\n', resultsFair.sumTotalDV01);
    fprintf('Zero upfront total sum     : %.6f EUR / bp\n', resultsZero.sumTotalDV01);
    fprintf('============================================================\n');

    if max(abs(diffPartial)) < 1e-8 && max(abs(diffTotal)) < 1e-8
        fprintf('\nDV01 does NOT depend on upfront.\n\n');
    else
        fprintf('\nWarning: DV01 appears to depend on upfront. Check MtM definition.\n\n');
    end

end