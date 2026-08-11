function pricesCaps = computeCapPricesSurfaceByColumn(discounts, forwardRates, ...
                                                      delta, resetTimes, ...
                                                      flatVols, strikes, matIdx)
%COMPUTECAPPRICESSURFACEBYCOLUMN Compute Black cap prices from flat cap vols.
%
%   The first caplet is excluded because it is already fixed at t0.
%
%   Therefore, a cap with maturity index matIdx(iMat) contains caplets:
%
%       2 : matIdx(iMat)-1
%
%   rather than:
%
%       1 : matIdx(iMat)-1
%
%   This makes the target cap prices consistent with a volatility matrix of
%   size [nCaplets-1 x nStrikes].

    nMaturities = numel(matIdx);
    nStrikes = numel(strikes);
    nCapletsTotal = numel(forwardRates);

    pricesCaps = zeros(nMaturities, nStrikes);

    paymentDiscountMatrix = repmat(discounts(2:end), nStrikes, 1);
    forwardRateMatrix = repmat(forwardRates, nStrikes, 1);
    deltaMatrix = repmat(delta, nStrikes, 1);
    resetTimeMatrix = repmat(resetTimes, nStrikes, 1);
    strikeMatrix = repmat(strikes(:), 1, nCapletsTotal);

    for maturityIdx = 1:nMaturities

        % Exclude first fixed caplet.
        capletIdx = 2:(matIdx(maturityIdx) - 1);

        if isempty(capletIdx)
            pricesCaps(maturityIdx, :) = zeros(1, nStrikes);
            continue
        end

        volatilityMatrix = repmat(flatVols(maturityIdx, :).', 1, numel(capletIdx));

        capletPrices = computeCapletPriceBlack( ...
            paymentDiscountMatrix(:, capletIdx), ...
            forwardRateMatrix(:, capletIdx), ...
            deltaMatrix(:, capletIdx), ...
            resetTimeMatrix(:, capletIdx), ...
            volatilityMatrix, ...
            strikeMatrix(:, capletIdx));

        pricesCaps(maturityIdx, :) = sum(capletPrices, 2).';

    end

end