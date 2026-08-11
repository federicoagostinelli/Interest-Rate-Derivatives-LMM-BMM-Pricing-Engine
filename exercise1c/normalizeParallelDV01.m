function results = normalizeParallelDV01(resultsRaw, shockSize, scaleDV01)
%NORMALIZEPARALLELDV01 Normalize raw parallel MtM changes to EUR / bp.

    results = resultsRaw;

    results.shockSize = shockSize;

    results.partialDV01 = ...
        resultsRaw.partialDV01 * scaleDV01;

    results.totalDV01 = ...
        resultsRaw.totalDV01 * scaleDV01;

    results.diff = ...
        results.totalDV01 - results.partialDV01;

end