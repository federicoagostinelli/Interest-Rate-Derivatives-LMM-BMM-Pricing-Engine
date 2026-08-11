function plotCalibratedVolsSelected(dates, vols, surface, selectedStrikes, modelType)
%PLOTCALIBRATEDVOLSSELECTED Plot selected calibrated volatility curves.
%
%   The first caplet fixing at the reference date is excluded from the
%   calibrated volatility matrix. Therefore:
%
%       size(vols,1) = numel(dates) - 2
%
%   and
%
%       vols(i,:) corresponds to the caplet resetting at dates(i+1).

    if nargin < 5 || isempty(modelType)
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

    % Exclude the first fixing date dates(1). The first volatility row is
    % associated with the caplet resetting at dates(2).
    resetTimes = yearfrac(refDate, dates(2:end-1), 3);

    figure;
    hold on;
    grid on;

    for selectedStrikeIdx = 1:numel(selectedStrikes)

        [~, strikeIdx] = min(abs(surface.strikes - selectedStrikes(selectedStrikeIdx)));

        plot(resetTimes, 100 * vols(:, strikeIdx), ...
            'LineWidth', 1.5, ...
            'DisplayName', sprintf('K = %.2f%%', 100 * surface.strikes(strikeIdx)));

    end

    xlabel('Reset time');

    switch modelType
        case "LMM"
            ylabel('LMM caplet volatility (%)');
            titleText = 'Selected Calibrated LMM Caplet Volatilities';

        case "BMM"
            ylabel('BMM caplet volatility (%)');
            titleText = 'Selected Calibrated BMM Caplet Volatilities';
    end

    title(titleText);
    legend('Location', 'best');

    hold off;

end