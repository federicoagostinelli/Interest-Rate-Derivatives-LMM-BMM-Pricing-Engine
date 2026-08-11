function volsStrike = bootstrapStrikeLMM(strike, flatVolsStrike, pricesCapsStrike, ...
                                         discounts, forwardRates, delta, ...
                                         resetTimes, matIdx)
%BOOTSTRAPSTRIKELMM Bootstrap non-fixed LMM caplet volatilities for one strike.
%
%   volsStrike = BOOTSTRAPSTRIKELMM(strike, flatVolsStrike, pricesCapsStrike,
%   discounts, forwardRates, delta, resetTimes, matIdx) bootstraps the LMM
%   caplet volatilities corresponding to a single strike.
%
%   Convention
%       The first caplet is already fixed at t0 and is excluded from the
%       calibrated volatility vector.
%
%       Original tenor caplet index:
%           i = 1, ..., nCaplets
%
%       Calibrated volatility index:
%           volRow = i - 1
%
%       Therefore:
%           volsStrike(1) corresponds to caplet 2,
%           volsStrike(2) corresponds to caplet 3,
%           ...
%           volsStrike(nCaplets-1) corresponds to caplet nCaplets.
%
%   INPUT
%       strike
%           Strike in decimal units.
%
%       flatVolsStrike
%           [1 x nMaturities] flat cap vols for this strike.
%
%       pricesCapsStrike
%           [1 x nMaturities] target cap prices for this strike.
%
%       discounts
%           [1 x nDates] discount factors P(0,T_i).
%
%       forwardRates
%           [1 x nCaplets] initial forward rates.
%
%       delta
%           [1 x nCaplets] accrual factors.
%
%       resetTimes
%           [1 x nCaplets] reset times.
%
%       matIdx
%           [1 x nMaturities] maturity indices in tenor dates.
%
%   OUTPUT
%       volsStrike
%           [1 x nCaplets-1] bootstrapped caplet vols, excluding caplet 1.

    nMaturities = numel(matIdx);
    nCaplets = numel(delta);

    if nCaplets < 2
        error('At least two caplets are required to exclude the first fixed caplet.');
    end

    % Full internal vector, including the fixed first caplet.
    % The first caplet has zero volatility because it is already fixed at t0.
    volsFull = zeros(1, nCaplets);
    volsFull(1) = 0.0;

    % First quoted cap:
    % assign the first flat vol only to non-fixed caplets up to first maturity.
    idxFirstFull = 2:(matIdx(1) - 1);

    if ~isempty(idxFirstFull)
        volsFull(idxFirstFull) = flatVolsStrike(1);
    end

    for maturityIdx = 1:nMaturities-1

        idxOldFull = 2:(matIdx(maturityIdx) - 1);
        idxNewFull = matIdx(maturityIdx):(matIdx(maturityIdx + 1) - 1);

        % Remove the fixed first caplet if it ever appears.
        idxOldFull = idxOldFull(idxOldFull >= 2);
        idxNewFull = idxNewFull(idxNewFull >= 2);

        if isempty(idxNewFull)
            continue
        end

        targetPrice = pricesCapsStrike(maturityIdx + 1);

        if isempty(idxOldFull)
            oldPrice = 0.0;
        else
            oldPrice = sum(computeCapletPriceBlack( ...
                discounts(idxOldFull + 1), ...
                forwardRates(idxOldFull), ...
                delta(idxOldFull), ...
                resetTimes(idxOldFull), ...
                volsFull(idxOldFull), ...
                strike));
        end

        previousCapletIdx = idxNewFull(1) - 1;

        if previousCapletIdx < 2
            sigmaStart = flatVolsStrike(maturityIdx);
            timeStart = resetTimes(idxNewFull(1));
        else
            sigmaStart = volsFull(previousCapletIdx);
            timeStart = resetTimes(previousCapletIdx);
        end

        timeEnd = resetTimes(idxNewFull(end));

        if abs(timeEnd - timeStart) < 1.0e-14
            weights = ones(size(idxNewFull));
        else
            weights = (resetTimes(idxNewFull) - timeStart) ./ (timeEnd - timeStart);
        end

        objective = @(sigmaEnd) ...
            oldPrice + ...
            sum(computeCapletPriceBlack( ...
                discounts(idxNewFull + 1), ...
                forwardRates(idxNewFull), ...
                delta(idxNewFull), ...
                resetTimes(idxNewFull), ...
                sigmaStart + weights .* (sigmaEnd - sigmaStart), ...
                strike)) ...
            - targetPrice;

        sigmaEnd = fzero(objective, flatVolsStrike(maturityIdx + 1));

        volsFull(idxNewFull) = sigmaStart + weights .* (sigmaEnd - sigmaStart);

    end

    % Return only non-fixed caplets.
    volsStrike = volsFull(2:end);

end