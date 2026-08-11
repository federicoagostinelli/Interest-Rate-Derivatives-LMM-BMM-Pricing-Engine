function capPrices = computeBmmCapPricesSurfaceByColumn( ...
    discounts, forwardRates, accrualFactors, resetTimes, ...
    flatVols, strikes, maturityDateIdx)
%COMPUTEBMMCAPPRICESSURFACEBYCOLUMN Compute BMM cap prices from flat vols.
%
%   capPrices = computeBmmCapPricesSurfaceByColumn( ...
%       discounts, forwardRates, accrualFactors, resetTimes, ...
%       flatVols, strikes, maturityDateIdx)
%
%   computes target cap prices from quoted flat cap volatilities under the
%   BMM caplet pricing formula.
%
%   A cap maturing on tenor date T_m contains caplets:
%
%       1 : m - 1
%
%   The first caplet is included in the target cap price. Since its reset
%   time is zero, it is valued deterministically by computeBmmCapletPrice.
%
%   This is consistent with the bootstrap routine, which excludes the first
%   caplet from the calibrated volatility vector but includes its
%   deterministic value when matching cap prices.
%
%   ASSUMPTIONS:
%       - discounts has length nCaplets + 1.
%       - forwardRates, accrualFactors and resetTimes have length nCaplets.
%       - flatVols has size [nMaturities x nStrikes].
%       - strikes has length nStrikes.
%       - maturityDateIdx contains tenor-date indices.
%       - A cap with maturityDateIdx = m contains caplets 1:(m-1).
%
%   INPUTS:
%       discounts
%           Discount factors on the tenor date grid.
%
%       forwardRates
%           Forward rates for each caplet period.
%
%       accrualFactors
%           Accrual factors for each caplet period.
%
%       resetTimes
%           Reset times for each caplet period.
%
%       flatVols
%           Flat cap volatility surface. Rows are cap maturities, columns
%           are strikes.
%
%       strikes
%           Strike grid.
%
%       maturityDateIdx
%           Tenor-date indices corresponding to cap maturities.
%
%   OUTPUT:
%       capPrices
%           Matrix [nMaturities x nStrikes] of unit-notional cap prices.

    numberOfMaturities = numel(maturityDateIdx);
    numberOfStrikes = numel(strikes);

    strikes = strikes(:);

    capPrices = zeros(numberOfMaturities, numberOfStrikes);

    for maturityIdx = 1:numberOfMaturities

        capletIdx = 1:(maturityDateIdx(maturityIdx) - 1);
        numberOfCapletsInCap = numel(capletIdx);

        if numberOfCapletsInCap == 0
            continue
        end

        paymentDiscountMatrix = repmat( ...
            discounts(capletIdx + 1), ...
            numberOfStrikes, ...
            1);

        forwardRateMatrix = repmat( ...
            forwardRates(capletIdx), ...
            numberOfStrikes, ...
            1);

        accrualFactorMatrix = repmat( ...
            accrualFactors(capletIdx), ...
            numberOfStrikes, ...
            1);

        resetTimeMatrix = repmat( ...
            resetTimes(capletIdx), ...
            numberOfStrikes, ...
            1);

        strikeMatrix = repmat( ...
            strikes, ...
            1, ...
            numberOfCapletsInCap);

        volatilityMatrix = repmat( ...
            flatVols(maturityIdx, :).', ...
            1, ...
            numberOfCapletsInCap);

        capletPrices = computeBmmCapletPrice( ...
            paymentDiscountMatrix, ...
            forwardRateMatrix, ...
            accrualFactorMatrix, ...
            resetTimeMatrix, ...
            volatilityMatrix, ...
            strikeMatrix);

        capPrices(maturityIdx, :) = sum(capletPrices, 2).';

    end

end