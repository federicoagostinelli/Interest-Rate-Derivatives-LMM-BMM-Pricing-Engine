function [bFixed, bPath, capletVols, dt] = simulateBMMSpotMeasure( ...
    market, volsBMM, nPaths, seed)
%SIMULATEBMMSPOTMEASURE Simulate BMM forward ZCBs under the spot measure.
%
%   [bFixed, bPath, capletVols, dt] = simulateBMMSpotMeasure( ...
%       market, volsBMM, nPaths, seed)
%
%   simulates the BMM forward zero-coupon bond state variables:
%
%       B_i(t) = P(t,T_{i+1}) / P(t,T_i)
%
%   under the spot measure.
%
%   MATLAB tenor convention:
%
%       period i = [market.tenor.dates(i), market.tenor.dates(i+1)]
%
%   Therefore:
%
%       bFixed(:,i) = B_i(T_i)
%
%   The Libor fixing is:
%
%       L_i(T_i) = (1 / B_i(T_i) - 1) / delta_i
%
%   where delta_i is the ACT/360 accrual factor. The simulation time step
%   dt_i is ACT/365 and is used only in the stochastic evolution.
%
%   Volatility convention:
%
%       volsBMM has size [nCaplets - 1 x nStrikes]
%
%   because the first caplet is fixed at t0:
%
%       i = 1  -> capletVols(1) = 0
%       i >= 2 -> volsBMM(i - 1,:)
%
%   Spot-measure dynamics:
%
%       dB_i / B_i = mu_i dt - beta_i dW_i
%
%   where:
%
%       beta_i = (1 - B_i) * capletVols(i)
%
%   and, during step T_k -> T_{k+1}:
%
%       mu_i = - beta_i * sum_{j=k+1}^{i-1} rho(i,j) beta_j
%
%   INPUTS:
%       market
%           Market struct created by initializeInterestRateMarket.
%
%       volsBMM
%           BMM volatility matrix in decimal units.
%
%       nPaths
%           Number of Monte Carlo paths. If omitted or empty, 10000 is used.
%
%       seed
%           Random seed. If omitted or empty, current RNG state is used.
%
%   OUTPUTS:
%       bFixed
%           Matrix [nPaths x nCaplets] of fixed B_i(T_i).
%
%       bPath
%           Array [nPaths x nCaplets x nDates] containing the simulated
%           state path.
%
%       capletVols
%           Vector [nCaplets x 1] of interpolated BMM caplet volatilities.
%
%       dt
%           Vector [nCaplets x 1] of ACT/365 simulation time steps.

    if nargin < 3 || isempty(nPaths)
        nPaths = 10000;
    end

    if nargin >= 4 && ~isempty(seed)
        rng(seed);
    end

    %% Market quantities

    dates = market.tenor.dates(:);
    nDates = numel(dates);
    nCaplets = nDates - 1;

    dt = market.tenor.dt(:);
    accrualFactors = market.tenor.delta(:);

    b0 = market.tenor.forwardZCB(:);

    rho = ...
        (market.rho + market.rho.') / 2.0;

    cholRho = ...
        chol(rho, 'lower');

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

    %% Allocate state and outputs

    bState = ...
        repmat(b0.', nPaths, 1);

    bFixed = ...
        zeros(nPaths, nCaplets);

    bPath = ...
        zeros(nPaths, nCaplets, nDates);

    bPath(:, :, 1) = bState;

    % First caplet fixes immediately at t0.
    bFixed(:, 1) = b0(1);

    %% Spot-measure simulation

    for timeIdx = 1:(nCaplets - 1)

        normalShocks = ...
            randn(nPaths, nCaplets);

        correlatedShocks = ...
            normalShocks * cholRho.';

        for pathIdx = 1:nPaths

            beta = zeros(nCaplets, 1);

            for capletIdx = (timeIdx + 1):nCaplets

                beta(capletIdx) = ...
                    (1.0 - bState(pathIdx, capletIdx)) ...
                    * capletVols(capletIdx);

            end

            for capletIdx = (timeIdx + 1):nCaplets

                driftSum = 0.0;

                for driftIdx = (timeIdx + 1):(capletIdx - 1)

                    driftSum = ...
                        driftSum ...
                        + rho(capletIdx, driftIdx) * beta(driftIdx);

                end

                drift = ...
                    -beta(capletIdx) * driftSum;

                logIncrement = ...
                    (drift - 0.5 * beta(capletIdx)^2) * dt(timeIdx) ...
                    - beta(capletIdx) ...
                    * sqrt(dt(timeIdx)) ...
                    * correlatedShocks(pathIdx, capletIdx);

                bState(pathIdx, capletIdx) = ...
                    bState(pathIdx, capletIdx) ...
                    * exp(logIncrement);

            end

        end

        % At T_{k+1}, B_{k+1} fixes.
        bFixed(:, timeIdx + 1) = ...
            bState(:, timeIdx + 1);

        % Store full state path at T_{k+1}.
        bPath(:, :, timeIdx + 1) = ...
            bState;

    end

end