function [probCorrected, probUncorr, vega, slope] = computeDigitalSmileCorrection( ...
    Ppay, F, delta, resetTime, K, volsAtResetTimes, strikes)
%COMPUTEDIGITALSMILECORRECTION Compute smile-corrected digital probabilities.
%
%   [probCorrected, probUncorr, vega, slope] = ...
%       computeDigitalSmileCorrection( ...
%           Ppay, F, delta, resetTime, K, volsAtResetTimes, strikes)
%
%   computes the uncorrected and smile-corrected Black digital probability:
%
%       P(L > K)
%
%   where L is the forward Libor/Euribor rate fixing at resetTime and K is
%   the digital barrier.
%
%   Under Black-76 with constant volatility, the uncorrected digital
%   probability is:
%
%       probUncorr = N(d2)
%
%   If the volatility depends on strike, sigma = sigma(K), the digital
%   probability is corrected using the total derivative of the Black caplet
%   price with respect to strike:
%
%       probCorrected = N(d2)
%                       - F * sqrt(T) * n(d1) * dSigma/dK
%
%   where:
%
%       T          = resetTime
%       F          = forward rate
%       K          = barrier / strike
%       dSigma/dK  = local slope of the volatility smile at K
%
%   The correction is obtained from:
%
%       Digital = - d CapletPrice / dK
%
%   after removing the common discounting and accrual factor
%   P(0,T_pay) * delta.
%
%   INPUTS:
%       Ppay
%           Payment discount factor P(0,T_pay). Scalar or row-compatible
%           with F.
%
%       F
%           Forward Libor/Euribor rate, in decimal units.
%
%       delta
%           Accrual factor of the coupon period.
%
%       resetTime
%           Time to reset, in years.
%
%       K
%           Barrier / strike, in decimal units.
%
%       volsAtResetTimes
%           Volatility smile at the relevant reset time, in decimal units.
%
%       strikes
%           Strike grid corresponding to volsAtResetTimes, in decimal units.
%
%   OUTPUTS:
%       probCorrected
%           Smile-corrected digital probability P(L > K).
%
%       probUncorr
%           Uncorrected Black-76 digital probability N(d2).
%
%       vega
%           Black caplet vega, excluding notional but including discounting
%           and accrual:
%
%               Ppay * delta * F * sqrt(resetTime) * n(d1)
%
%       slope
%           Volatility smile slope dSigma/dK evaluated at K.
%
%% Shape convention

    Ppay = Ppay(:).';
    F = F(:).';
    delta = delta(:).';
    resetTime = resetTime(:).';

    %% Volatility and smile slope at the barrier

    [sigma, slope] = computeVolAndSlope( ...
        strikes, ...
        volsAtResetTimes, ...
        K);

    %% Output initialization

    vega = zeros(size(F));
    probUncorr = zeros(size(F));
    correction = zeros(size(F));

    %% Black region

    idxBlack = ...
        resetTime > 0 ...
        & sigma > 0 ...
        & F > 0 ...
        & K > 0;

    if any(idxBlack)

        stdDev = sigma(idxBlack) .* sqrt(resetTime(idxBlack));

        d1 = ...
            (log(F(idxBlack) ./ K) ...
            + 0.5 .* stdDev.^2) ...
            ./ stdDev;

        d2 = d1 - stdDev;

        probUncorr(idxBlack) = normcdf(d2);

        vega(idxBlack) = ...
            Ppay(idxBlack) ...
            .* delta(idxBlack) ...
            .* F(idxBlack) ...
            .* sqrt(resetTime(idxBlack)) ...
            .* normpdf(d1);

        correction(idxBlack) = ...
            -F(idxBlack) ...
            .* sqrt(resetTime(idxBlack)) ...
            .* normpdf(d1) ...
            .* slope(idxBlack);

    end

    %% Deterministic region

    idxIntrinsic = ~idxBlack;

    if any(idxIntrinsic)
        probUncorr(idxIntrinsic) = double(F(idxIntrinsic) > K);
    end

    %% Smile-corrected digital probability

    probCorrected = probUncorr + correction;

end