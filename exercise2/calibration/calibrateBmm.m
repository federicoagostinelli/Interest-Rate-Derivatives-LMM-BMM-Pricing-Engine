function volsBMM = calibrateBmm(market)
%CALIBRATEBMM Bootstrap BMM caplet volatilities from cap volatilities.
%
%   volsBMM = calibrateBmm(market)
%
%   bootstraps BMM caplet volatilities from the flat Black cap volatility
%   surface stored in:
%
%       market.surface.vols
%
%   The function uses the precomputed tenor quantities stored in:
%
%       market.tenor.discounts
%       market.tenor.delta
%       market.tenor.resetTimes
%       market.tenor.forwardRates
%       market.tenor.times
%
%   Therefore it does not recompute accrual factors, reset times, discount
%   factors or forward rates.
%
%   The first caplet is excluded from the calibrated volatility matrix
%   because its reset time is zero and the corresponding rate is already
%   fixed at the valuation date.
%
%   If the market tenor grid contains nCaplets periods, the output has:
%
%       nCaplets - 1
%
%   rows.
%
%   Indexing convention:
%
%       volsBMM(rowIdx, :) corresponds to capletIdx = rowIdx + 1
%
%   Therefore:
%
%       volsBMM(1, :)  corresponds to caplet 2
%       volsBMM(2, :)  corresponds to caplet 3
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
%       volsBMM
%           [nCaplets - 1 x nStrikes] matrix of calibrated BMM caplet
%           volatilities in decimal units. Rows correspond to
%           market.tenor.resetTimes(2:end), columns to market.surface.strikes.

    %% Market inputs

    strikes = market.surface.strikes(:).';
    flatVols = market.surface.vols;

    discounts = market.tenor.discounts(:).';
    forwardRates = market.tenor.forwardRates(:).';
    accrualFactors = market.tenor.delta(:).';
    resetTimes = market.tenor.resetTimes(:).';
    tenorTimes = market.tenor.times(:).';

    maturityTimes = market.surface.maturities(:).';

    numberOfStrikes = numel(strikes);

    %% Map quoted cap maturities to tenor-date indices

    maturityDateIdx = interp1( ...
        tenorTimes, ...
        1:numel(tenorTimes), ...
        maturityTimes, ...
        'linear', ...
        'extrap');

    maturityDateIdx = round(maturityDateIdx);

    %% Compute target cap prices from quoted flat BMM vols

    capPrices = computeBmmCapPricesSurfaceByColumn( ...
        discounts, ...
        forwardRates, ...
        accrualFactors, ...
        resetTimes, ...
        flatVols, ...
        strikes, ...
        maturityDateIdx);

    %% Bootstrap each strike independently

    volColumns = arrayfun( ...
        @(strikeIdx) bootstrapStrikeBmm( ...
            strikes(strikeIdx), ...
            flatVols(:, strikeIdx).', ...
            capPrices(:, strikeIdx).', ...
            discounts, ...
            forwardRates, ...
            accrualFactors, ...
            resetTimes, ...
            maturityDateIdx), ...
        1:numberOfStrikes, ...
        'UniformOutput', false);

    volsBMM = cell2mat( ...
        cellfun(@(x) x(:), volColumns, 'UniformOutput', false));

end