function shockedMarkets = buildVegaShockedMarkets( ...
    marketBase, vegaWeights6y, vegaWeights10y, bumpVol)
%BUILDVEGASHOCKEDMARKETS Build bumped volatility-surface market structs.
%
%   shockedMarkets = buildVegaShockedMarkets( ...
%       marketBase, vegaWeights6y, vegaWeights10y, bumpVol)
%
%   creates four market structs by bumping the quoted flat Black cap
%   volatility surface:
%
%       market6yUp
%       market6yDown
%       market10yUp
%       market10yDown
%
%   INPUTS:
%       marketBase
%           Base market struct.
%
%       vegaWeights6y
%           Column vector of 0y-6y Vega bucket weights, one per quoted cap
%           surface maturity.
%
%       vegaWeights10y
%           Column vector of 6y-10y Vega bucket weights, one per quoted cap
%           surface maturity.
%
%       bumpVol
%           Absolute volatility bump in decimal units.
%
%   OUTPUT:
%       shockedMarkets
%           Struct containing the four bumped market structs.

    numberOfStrikes = numel(marketBase.surface.strikes);

    bumpMatrix6y = ...
        vegaWeights6y(:) * ones(1, numberOfStrikes);

    bumpMatrix10y = ...
        vegaWeights10y(:) * ones(1, numberOfStrikes);

    shockedMarkets = struct();

    shockedMarkets.market6yUp = marketBase;
    shockedMarkets.market6yDown = marketBase;
    shockedMarkets.market10yUp = marketBase;
    shockedMarkets.market10yDown = marketBase;

    shockedMarkets.market6yUp.surface.vols = ...
        marketBase.surface.vols ...
        + bumpVol * bumpMatrix6y;

    shockedMarkets.market6yDown.surface.vols = ...
        marketBase.surface.vols ...
        - bumpVol * bumpMatrix6y;

    shockedMarkets.market10yUp.surface.vols = ...
        marketBase.surface.vols ...
        + bumpVol * bumpMatrix10y;

    shockedMarkets.market10yDown.surface.vols = ...
        marketBase.surface.vols ...
        - bumpVol * bumpMatrix10y;

end