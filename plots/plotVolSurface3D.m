function plotVolSurface3D(dates, vols, strikes, modelType)
%PLOTVOLSURFACE3D Plot calibrated caplet volatility surface in 3D.
%
%   The first caplet fixing at the reference date is excluded from the
%   calibrated volatility matrix. Therefore:
%
%       size(vols,1) = numel(dates) - 2
%
%   and
%
%       vols(i,j)
%
%   corresponds to:
%
%       reset date dates(i+1)
%       strike strikes(j)

    if nargin < 4 || isempty(modelType)
        modelType = 'LMM';
    end

    modelType = upper(string(modelType));

    if modelType ~= "LMM" && modelType ~= "BMM"
        error('modelType must be either ''LMM'' or ''BMM''.');
    end

    refDate = dates(1);

    numberOfVolRows = size(vols, 1);
    expectedRows = numel(dates) - 2;

    if numberOfVolRows ~= expectedRows
        error(['vols must have %d rows because the first fixed caplet is excluded. ', ...
               'Received %d rows.'], expectedRows, numberOfVolRows);
    end

    resetTimes = yearfrac(refDate, dates(2:end-1), 3);

    [strikeGrid, timeGrid] = meshgrid(strikes, resetTimes);

    figure;

    surf(strikeGrid * 100, timeGrid, vols * 100);

    shading interp;
    grid on;
    box on;

    xlabel('Strike (%)');
    ylabel('Reset time');

    switch modelType
        case "LMM"
            zlabel('LMM caplet volatility (%)');
            titleText = 'Calibrated LMM Caplet Volatility Surface';

        case "BMM"
            zlabel('BMM caplet volatility (%)');
            titleText = 'Calibrated BMM Caplet Volatility Surface';
    end

    title(titleText);

    colorbar;

    view(45, 30);

end