function [shockedMarkets, shockedProducts] = buildShockedMarketsAndProducts( ...
    curveDatesSet, curveRatesSet, shockTables, productContract)
%BUILDSHOCKEDMARKETSANDPRODUCTS Build shocked markets and prepared products.
%
%   [shockedMarkets, shockedProducts] = buildShockedMarketsAndProducts( ...
%       curveDatesSet, curveRatesSet, shockTables, productContract)
%
%   bootstraps one shocked discount curve for each shock timetable, builds
%   the corresponding interest-rate market, and prepares the contractual
%   product on each shocked market.
%
%   INPUTS:
%       curveDatesSet
%           Struct containing bootstrap instrument dates.
%
%       curveRatesSet
%           Struct containing bootstrap market quotes.
%
%       shockTables
%           Cell array of shock timetables. Each timetable must be accepted
%           by bootstrapShocked and contain a variable named 'Shock'.
%
%       productContract
%           Contractual product struct, not yet prepared on a market.
%
%   OUTPUTS:
%       shockedMarkets
%           Cell array of shocked market structs.
%
%       shockedProducts
%           Cell array of product structs prepared on the corresponding
%           shocked markets.

    nShocks = numel(shockTables);

    shockedMarkets = cell(nShocks, 1);
    shockedProducts = cell(nShocks, 1);

    for shockIdx = 1:nShocks

        [datesShocked, discountsShocked, zeroRatesShocked] = ...
            bootstrapShocked( ...
                curveDatesSet, ...
                curveRatesSet, ...
                shockTables{shockIdx});

        shockedMarkets{shockIdx} = initializeInterestRateMarket( ...
            datesShocked, ...
            discountsShocked, ...
            zeroRatesShocked);

        shockedProducts{shockIdx} = prepareProductForPricing( ...
            productContract, ...
            shockedMarkets{shockIdx});

    end

end