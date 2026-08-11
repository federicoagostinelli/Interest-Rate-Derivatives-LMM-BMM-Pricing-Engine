function printExercise1fReport( ...
    useSmileCorrection, upfront, bumpVol, reportedVolShift, ...
    bondVegaBuckets, capStrikes, vegaMatrix, ...
    capNotionalsBackward, capNotionalsExact, ...
    vegaResidualBackward, vegaResidualExact)
%PRINTEXERCISE1FREPORT Print Vega bucket hedge diagnostics.
%
%   printExercise1fReport( ...
%       useSmileCorrection, upfront, bumpVol, reportedVolShift, ...
%       bondVegaBuckets, capStrikes, vegaMatrix, ...
%       capNotionalsBackward, capNotionalsExact, ...
%       vegaResidualBackward, vegaResidualExact)
%
%   prints Exercise 1f diagnostics:
%
%       - pricing convention;
%       - volatility bump convention;
%       - structured bond Vega buckets;
%       - ATM hedge cap strikes;
%       - cap Vega matrix;
%       - backward hedge notionals and residuals;
%       - exact hedge notionals and residuals.
%
%   OUTPUT:
%       None. This function prints to the command window.

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' Exercise 1f - Vega Bucket Hedging\n');
    fprintf('============================================================\n');
    fprintf('Pricing convention        : %s\n', ...
        getPricingLabel(useSmileCorrection));
    fprintf('Upfront used              : %.8f %%\n', ...
        100.0 * upfront);
    fprintf('Vol bump used             : %.6f %%\n', ...
        100.0 * bumpVol);
    fprintf('Reported Vega shift       : %.2f %%\n', ...
        100.0 * reportedVolShift);

    fprintf('------------------------------------------------------------\n');
    fprintf(' Structured bond Vega buckets\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('Bond Vega bucket 0y-6y    : %.6f EUR\n', bondVegaBuckets(1));
    fprintf('Bond Vega bucket 6y-10y   : %.6f EUR\n', bondVegaBuckets(2));

    fprintf('------------------------------------------------------------\n');
    fprintf(' ATM hedge cap strikes\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('ATM strike Cap 6y         : %.6f %%\n', 100.0 * capStrikes(1));
    fprintf('ATM strike Cap 10y        : %.6f %%\n', 100.0 * capStrikes(2));

    fprintf('------------------------------------------------------------\n');
    fprintf(' Cap Vega matrix\n');
    fprintf(' Rows: Vega buckets, columns: 6y / 10y caps\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('%12s %18s %18s\n', ...
        'Bucket', ...
        'Cap 6y', ...
        'Cap 10y');

    fprintf('%12s %18.6f %18.6f\n', ...
        '0y-6y', ...
        vegaMatrix(1, 1), ...
        vegaMatrix(1, 2));

    fprintf('%12s %18.6f %18.6f\n', ...
        '6y-10y', ...
        vegaMatrix(2, 1), ...
        vegaMatrix(2, 2));

    fprintf('------------------------------------------------------------\n');
    fprintf(' Hedge notionals - backward substitution\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('Notional Cap 6y           : %.2f EUR\n', capNotionalsBackward(1));
    fprintf('Notional Cap 10y          : %.2f EUR\n', capNotionalsBackward(2));

    fprintf('------------------------------------------------------------\n');
    fprintf(' Vega residual - backward substitution\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('Residual bucket 0y-6y     : %.8e EUR\n', vegaResidualBackward(1));
    fprintf('Residual bucket 6y-10y    : %.8e EUR\n', vegaResidualBackward(2));

    fprintf('------------------------------------------------------------\n');
    fprintf(' Hedge notionals - exact linear solve\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('Notional Cap 6y           : %.2f EUR\n', capNotionalsExact(1));
    fprintf('Notional Cap 10y          : %.2f EUR\n', capNotionalsExact(2));

    fprintf('------------------------------------------------------------\n');
    fprintf(' Vega residual - exact linear solve\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('Residual bucket 0y-6y     : %.8e EUR\n', vegaResidualExact(1));
    fprintf('Residual bucket 6y-10y    : %.8e EUR\n', vegaResidualExact(2));

    fprintf('============================================================\n\n');

end