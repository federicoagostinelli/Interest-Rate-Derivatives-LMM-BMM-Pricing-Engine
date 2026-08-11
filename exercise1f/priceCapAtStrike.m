function price = priceCapAtStrike(market, volsLMM, strike, capMaturityYears)
%PRICECAPATSTRIKE Price a cap at an off-grid strike using LMM caplet vols.
%
%   price = priceCapAtStrike(market, volsLMM, strike, capMaturityYears)
%
%   prices a cap with unit notional by interpolating calibrated LMM caplet
%   volatilities along the strike dimension and summing the corresponding
%   Black caplet prices.
%
%   The calibrated LMM volatility matrix is assumed to exclude the first
%   already-fixed caplet:
%
%       volsLMM(1,:) corresponds to caplet 2
%       volsLMM(2,:) corresponds to caplet 3
%       ...
%
%   Therefore volsLMM rows are aligned with:
%
%       market.tenor.resetTimes(2:end)
%
%   For a cap maturing on tenor date T_m, this function includes caplets:
%
%       2 : m - 1
%
%   consistently with the LMM calibration convention.
%
%   INPUTS:
%       market
%           Market struct created by initializeInterestRateMarket.
%
%       volsLMM
%           Calibrated LMM caplet volatility matrix in decimal units.
%           Rows are aligned with market.tenor.resetTimes(2:end), columns
%           with market.surface.strikes.
%
%       strike
%           Cap strike in decimal units.
%
%       capMaturityYears
%           Cap maturity in years. Must be one of market.surface.maturityYears.
%
%   OUTPUT:
%       price
%           Black cap price for unit notional.

    maturityIdx = find( ...
        market.surface.maturityYears == capMaturityYears, ...
        1, ...
        'first');

    if isempty(maturityIdx)
        error( ...
            'priceCapAtStrike:InvalidMaturity', ...
            'Cap maturity %.6g years is not in market.surface.maturityYears.', ...
            capMaturityYears);
    end

    capMaturityDate = market.surface.maturityDates(maturityIdx);

    capMaturityTime = yearfrac( ...
        market.dateInfo.refDate, ...
        capMaturityDate, ...
        market.dateInfo.blackDayCount);

    [~, tenorMaturityIdx] = min( ...
        abs(market.tenor.times(:) - capMaturityTime));

    capletIdx = 2:(tenorMaturityIdx - 1);

    if isempty(capletIdx)
        price = 0.0;
        return
    end

    volsAtStrike = interp1( ...
        market.surface.strikes(:), ...
        volsLMM(:, :).', ...
        strike, ...
        'spline', ...
        'extrap');

    volsAtStrike = volsAtStrike(:);

    volsForCap = volsAtStrike(capletIdx - 1).';

    price = sum(computeCapletPriceBlack( ...
        market.tenor.discounts(capletIdx + 1), ...
        market.tenor.forwardRates(capletIdx), ...
        market.tenor.delta(capletIdx), ...
        market.tenor.resetTimes(capletIdx), ...
        volsForCap, ...
        strike));

end