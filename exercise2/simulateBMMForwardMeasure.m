function [bTarget, stateIdx, capletVols, dt] = simulateBMMForwardMeasure( ...
    market, volsBMM, targetIdx, lastIdx, nPaths, seed)
%SIMULATEBMMFORWARDMEASURE Simulate BMM forward ZCBs under T_target measure.
%
%   [bTarget, stateIdx, capletVols, dt] = simulateBMMForwardMeasure( ...
%       market, volsBMM, targetIdx, lastIdx, nPaths, seed)
%
%   simulates the BMM forward zero-coupon bond state variables:
%
%       B_j(t) = P(t,T_{j+1}) / P(t,T_j)
%
%   for:
%
%       j = targetIdx, ..., lastIdx
%
%   under the T_target-forward measure.
%
%   The Libor relation is:
%
%       L_j(t) = (1 / B_j(t) - 1) / delta_j
%
%   where delta_j is the ACT/360 accrual factor. The simulation time step
%   dt_j is ACT/365 and is used only in the stochastic evolution.
%
%   Volatility convention:
%
%       volsBMM has size [nCaplets - 1 x nStrikes]
%
%   because the first caplet is fixed at t0:
%
%       j = 1  -> capletVols(1) = 0
%       j >= 2 -> volsBMM(j - 1,:)
%
%   Under the T_target-forward measure:
%
%       dB_j / B_j = mu_j dt - beta_j dW_j
%
%   with:
%
%       beta_j = (1 - B_j) * capletVols(j)
%
%       mu_j = - beta_j * sum_{h=targetIdx}^{j-1} rho(j,h) beta_h
%
%   INPUTS:
%       market
%           Market struct created by initializeInterestRateMarket.
%
%       volsBMM
%           BMM volatility matrix in decimal units.
%
%       targetIdx
%           Tenor index of the forward-measure date T_target.
%
%       lastIdx
%           Last simulated state index.
%
%       nPaths
%           Number of Monte Carlo paths. If omitted or empty, 10000 is used.
%
%       seed
%           Random seed. If omitted or empty, current RNG state is used.
%
%   OUTPUTS:
%       bTarget
%           Matrix [nPaths x nStates] of simulated B_j(T_target).
%
%       stateIdx
%           Row vector of simulated state indices.
%
%       capletVols
%           Vector [nCaplets x 1] of interpolated BMM caplet volatilities.
%
%       dt
%           Vector [nCaplets x 1] of ACT/365 simulation time steps.

    if nargin < 5 || isempty(nPaths)
        nPaths = 10000;
    end

    if nargin >= 6 && ~isempty(seed)
        rng(seed);
    end

    %% Market quantities

    dates = market.tenor.dates(:);
    nCaplets = numel(dates) - 1;

    dt = market.tenor.dt(:);
    accrualFactors = market.tenor.delta(:);

    b0 = market.tenor.forwardZCB(:);

    strikes = ...
        market.surface.strikes(:).';

    %% Initial forward rates implied by BMM state

    forwardRates0 = ...
        (1.0 ./ b0 - 1.0) ...
        ./ accrualFactors;

    %% Interpolate BMM caplet volatilities

    capletVols = zeros(nCaplets, 1);

    for capletIdx = 2:nCaplets

        capletVols(capletIdx) = interp1( ...
            strikes, ...
            volsBMM(capletIdx - 1, :), ...
            forwardRates0(capletIdx), ...
            'spline', ...
            'extrap');

        capletVols(capletIdx) = ...
            max(capletVols(capletIdx), 0.0);

    end

    %% State and correlation

    stateIdx = ...
        targetIdx:lastIdx;

    nStates = ...
        numel(stateIdx);

    rho = ...
        (market.rho + market.rho.') / 2.0;

    rhoSub = ...
        rho(stateIdx, stateIdx);

    rhoSub = ...
        (rhoSub + rhoSub.') / 2.0;

    cholRhoSub = ...
        chol(rhoSub, 'lower');

    bState = ...
        repmat(b0(stateIdx).', nPaths, 1);

    %% If target date is valuation date

    if targetIdx == 1
        bTarget = bState;
        return
    end

    %% Forward-measure simulation

    for timeIdx = 1:(targetIdx - 1)

        normalShocks = ...
            randn(nPaths, nStates);

        correlatedShocks = ...
            normalShocks * cholRhoSub.';

        for pathIdx = 1:nPaths

            beta = zeros(nStates, 1);

            for statePos = 1:nStates

                capletIdx = stateIdx(statePos);

                beta(statePos) = ...
                    (1.0 - bState(pathIdx, statePos)) ...
                    * capletVols(capletIdx);

            end

            for statePos = 1:nStates

                capletIdx = stateIdx(statePos);

                driftSum = 0.0;

                for driftIdx = targetIdx:(capletIdx - 1)

                    driftPos = ...
                        find(stateIdx == driftIdx, 1);

                    if ~isempty(driftPos)

                        driftSum = ...
                            driftSum ...
                            + rho(capletIdx, driftIdx) * beta(driftPos);

                    end

                end

                drift = ...
                    -beta(statePos) * driftSum;

                logIncrement = ...
                    (drift - 0.5 * beta(statePos)^2) * dt(timeIdx) ...
                    - beta(statePos) ...
                    * sqrt(dt(timeIdx)) ...
                    * correlatedShocks(pathIdx, statePos);

                bState(pathIdx, statePos) = ...
                    bState(pathIdx, statePos) ...
                    * exp(logIncrement);

            end

        end

    end

    bTarget = bState;

end