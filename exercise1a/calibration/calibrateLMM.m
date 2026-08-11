function volsLMM = calibrateLMM(market)
%CALIBRATELMM Bootstrap LMM caplet volatilities from cap volatilities.
%
%   volsLMM = calibrateLMM(market)
%
%   bootstraps LMM caplet volatilities from the flat Black cap volatility
%   surface stored in:
%
%       market.surface.vols
%
%   The function uses the precomputed quarterly tenor quantities stored in:
%
%       market.tenor.discounts
%       market.tenor.delta
%       market.tenor.resetTimes
%       market.tenor.forwardRates
%       market.tenor.times
%
%   No accrual factors, reset times, discount factors or forward rates are
%   recomputed here.
%
%   The first caplet is excluded because its reset time is zero. Therefore,
%   if the tenor grid contains nCaplets forward periods, the output has:
%
%       nCaplets - 1
%
%   rows.
%
%   Indexing convention:
%
%       volsLMM(rowIdx, :) corresponds to capletIdx = rowIdx + 1
%
%   Therefore:
%
%       volsLMM(1, :)  corresponds to the caplet on [T_1, T_2]
%       volsLMM(2, :)  corresponds to the caplet on [T_2, T_3]
%       ...
%
%   and the associated reset-time grid is:
%
%       market.tenor.resetTimes(2:end)
%
%   INPUT:
%       market
%           Market struct created by initializeInterestRateMarket.
%
%   OUTPUT:
%       volsLMM
%           [nCaplets - 1 x nStrikes] matrix of calibrated LMM caplet
%           volatilities in decimal units. Rows correspond to
%           market.tenor.resetTimes(2:end), columns to market.surface.strikes.

    %% Market inputs

    strikes = market.surface.strikes(:).';
    flatVols = market.surface.vols;

    discounts = market.tenor.discounts(:).';
    forwardRates = market.tenor.forwardRates(:).';
    delta = market.tenor.delta(:).';
    resetTimes = market.tenor.resetTimes(:).';
    tenorTimes = market.tenor.times(:).';

    maturityTimes = market.surface.maturities(:).';

    nStrikes = numel(strikes);
    nCaplets = numel(forwardRates);

    %% Map cap maturities to tenor date indices by linear interpolation in time

    maturityDateIdx = interp1( ...
        tenorTimes, ...
        1:numel(tenorTimes), ...
        maturityTimes, ...
        'linear', ...
        'extrap');

    maturityDateIdx = round(maturityDateIdx);

    maturityDateIdx = max(maturityDateIdx, 2);
    maturityDateIdx = min(maturityDateIdx, numel(tenorTimes));

    %% Compute target cap prices from quoted flat cap volatilities

    pricesCaps = computeCapPricesSurfaceByColumn( ...
        discounts, ...
        forwardRates, ...
        delta, ...
        resetTimes, ...
        flatVols, ...
        strikes, ...
        maturityDateIdx);

    %% Bootstrap each strike independently

    volColumns = arrayfun( ...
        @(strikeIdx) bootstrapStrikeLMM( ...
            strikes(strikeIdx), ...
            flatVols(:, strikeIdx).', ...
            pricesCaps(:, strikeIdx).', ...
            discounts, ...
            forwardRates, ...
            delta, ...
            resetTimes, ...
            maturityDateIdx), ...
        1:nStrikes, ...
        'UniformOutput', false);

    volsLMM = cell2mat( ...
        cellfun(@(x) x(:), volColumns, 'UniformOutput', false));

end