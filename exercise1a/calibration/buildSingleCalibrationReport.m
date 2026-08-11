function report = buildSingleCalibrationReport( ...
    reportName, priceFunction, dates, discounts, surface, volsModel, ...
    strikes, flatVols, forwardRates, delta, resetTimes, maturityDateIdx)
%BUILDSINGLECALIBRATIONREPORT Build one cap calibration report.
%
%   report = buildSingleCalibrationReport(...)
%
%   constructs target and reconstructed cap prices using the supplied caplet
%   pricing function.

    numberOfStrikes = numel(strikes);
    numberOfMaturities = numel(surface.maturities);

    marketPrices = zeros(numberOfMaturities, numberOfStrikes);
    modelPrices = zeros(numberOfMaturities, numberOfStrikes);

    for maturityIdx = 1:numberOfMaturities

        fullCapletIdx = 1:(maturityDateIdx(maturityIdx) - 1);

        paymentDiscounts = discounts(fullCapletIdx + 1);
        forwardRatesForCap = forwardRates(fullCapletIdx);
        accrualsForCap = delta(fullCapletIdx);
        resetTimesForCap = resetTimes(fullCapletIdx);

        stochasticCapletIdx = fullCapletIdx(fullCapletIdx >= 2);
        modelVolIdx = stochasticCapletIdx - 1;

        paymentDiscountsModel = discounts(stochasticCapletIdx + 1);
        forwardRatesModel = forwardRates(stochasticCapletIdx);
        accrualsModel = delta(stochasticCapletIdx);
        resetTimesModel = resetTimes(stochasticCapletIdx);

        for strikeIdx = 1:numberOfStrikes

            strike = strikes(strikeIdx);

            marketPrices(maturityIdx, strikeIdx) = sum(priceFunction( ...
                paymentDiscounts, ...
                forwardRatesForCap, ...
                accrualsForCap, ...
                resetTimesForCap, ...
                flatVols(maturityIdx, strikeIdx), ...
                strike));

            modelPrices(maturityIdx, strikeIdx) = sum(priceFunction( ...
                paymentDiscountsModel, ...
                forwardRatesModel, ...
                accrualsModel, ...
                resetTimesModel, ...
                volsModel(modelVolIdx, strikeIdx).', ...
                strike));

            if any(fullCapletIdx == 1)

                fixedCapletPrice = priceFunction( ...
                    discounts(2), ...
                    forwardRates(1), ...
                    delta(1), ...
                    resetTimes(1), ...
                    flatVols(maturityIdx, strikeIdx), ...
                    strike);

                modelPrices(maturityIdx, strikeIdx) = ...
                    modelPrices(maturityIdx, strikeIdx) + fixedCapletPrice;

            end

        end

    end

    absErrors = modelPrices - marketPrices;
    relErrors = absErrors ./ max(abs(marketPrices), eps);

    report = struct();

    report.modelType = char(reportName);
    report.marketPrices = marketPrices;
    report.modelPrices = modelPrices;
    report.absErrors = absErrors;
    report.relErrors = relErrors;
    report.maxAbsError = max(abs(absErrors), [], 'all');
    report.maxRelError = max(abs(relErrors), [], 'all');
    report.rmse = sqrt(mean(absErrors.^2, 'all'));

    report.dates = dates;
    report.discounts = discounts;
    report.surface = surface;

end