function volsStrike = bootstrapStrikeBmm( ...
    strike, flatVolsStrike, capPricesStrike, discounts, ...
    forwardRates, accrualFactors, resetTimes, maturityDateIdx)
%BOOTSTRAPSTRIKEBMM Bootstrap BMM caplet volatilities for one strike.
%
%   volsStrike = bootstrapStrikeBmm( ...
%       strike, flatVolsStrike, capPricesStrike, discounts, ...
%       forwardRates, accrualFactors, resetTimes, maturityDateIdx)
%
%   bootstraps BMM caplet volatilities for a single strike.
%
%   The first caplet has reset time equal to zero and is excluded from the
%   calibrated volatility vector. The output therefore contains one
%   volatility for each stochastic caplet:
%
%       caplet 2, caplet 3, ..., caplet nCaplets
%
%   Indexing convention:
%
%       volsStrike(i) corresponds to full caplet index i + 1
%
%   INPUTS:
%       strike
%           Strike in decimal units.
%
%       flatVolsStrike
%           Row vector of quoted flat BMM/Black cap volatilities for one
%           strike, one value per quoted cap maturity.
%
%       capPricesStrike
%           Row vector of target cap prices for one strike, one value per
%           quoted cap maturity.
%
%       discounts
%           Discount factors on the tenor date grid. Length nCaplets + 1.
%
%       forwardRates
%           Forward rates for each caplet period. Length nCaplets.
%
%       accrualFactors
%           Accrual factors for each caplet period. Length nCaplets.
%
%       resetTimes
%           Reset times for each caplet period. Length nCaplets.
%
%       maturityDateIdx
%           Tenor-date indices corresponding to quoted cap maturities.
%
%   OUTPUT:
%       volsStrike
%           Row vector [1 x nCaplets-1] of stripped BMM caplet
%           volatilities, excluding the first fixed caplet.

    numberOfMaturities = numel(maturityDateIdx);
    numberOfCaplets = numel(forwardRates);

    volsFull = zeros(1, numberOfCaplets);

    %% First quoted cap

    firstCapletIdx = 2:(maturityDateIdx(1) - 1);

    if ~isempty(firstCapletIdx)
        volsFull(firstCapletIdx) = flatVolsStrike(1);
    end

    %% Remaining quoted caps

    for maturityIdx = 1:(numberOfMaturities - 1)

        oldCapletIdx = 2:(maturityDateIdx(maturityIdx) - 1);
        newCapletIdx = max(2, maturityDateIdx(maturityIdx)):(maturityDateIdx(maturityIdx + 1) - 1);

        if isempty(newCapletIdx)
            continue
        end

        targetPrice = capPricesStrike(maturityIdx + 1);

        fixedCapletPrice = computeBmmCapletPrice( ...
            discounts(2), ...
            forwardRates(1), ...
            accrualFactors(1), ...
            resetTimes(1), ...
            flatVolsStrike(maturityIdx + 1), ...
            strike);

        oldPrice = ...
            fixedCapletPrice ...
            + sum(computeBmmCapletPrice( ...
                discounts(oldCapletIdx + 1), ...
                forwardRates(oldCapletIdx), ...
                accrualFactors(oldCapletIdx), ...
                resetTimes(oldCapletIdx), ...
                volsFull(oldCapletIdx), ...
                strike));

        previousCapletIdx = newCapletIdx(1) - 1;

        if previousCapletIdx < 2
            sigmaStart = flatVolsStrike(maturityIdx);
            timeStart = resetTimes(newCapletIdx(1));
        else
            sigmaStart = volsFull(previousCapletIdx);
            timeStart = resetTimes(previousCapletIdx);
        end

        timeEnd = resetTimes(newCapletIdx(end));

        if abs(timeEnd - timeStart) < 1.0e-12
            weights = ones(size(newCapletIdx));
        else
            weights = ...
                (resetTimes(newCapletIdx) - timeStart) ...
                ./ (timeEnd - timeStart);
        end

        objective = @(sigmaEnd) ...
            oldPrice ...
            + sum(computeBmmCapletPrice( ...
                discounts(newCapletIdx + 1), ...
                forwardRates(newCapletIdx), ...
                accrualFactors(newCapletIdx), ...
                resetTimes(newCapletIdx), ...
                sigmaStart + weights .* (sigmaEnd - sigmaStart), ...
                strike)) ...
            - targetPrice;

        logObjective = @(logSigmaEnd) objective(exp(logSigmaEnd));

        sigmaEnd = exp(fzero( ...
            logObjective, ...
            log(max(flatVolsStrike(maturityIdx + 1), 1.0e-8))));

        volsFull(newCapletIdx) = ...
            sigmaStart + weights .* (sigmaEnd - sigmaStart);

    end

    volsStrike = volsFull(2:end);

end