function mtm = computeSelectedMtm( ...
    market, product, volsLmm, upfront, useSmileCorrection)
%COMPUTESELECTEDMTM Compute MtM under the selected pricing convention.
%
%   mtm = computeSelectedMtm( ...
%       market, product, volsLmm, upfront, useSmileCorrection)
%
%   computes both smile-corrected and uncorrected mark-to-market values and
%   returns the one selected by useSmileCorrection.
%
%   INPUTS:
%       market
%           Market struct.
%
%       product
%           Product struct prepared on market.
%
%       volsLmm
%           LMM volatility matrix used for Party B pricing.
%
%       upfront
%           Upfront percentage used in the MtM calculation.
%
%       useSmileCorrection
%           true selects smile-corrected MtM; false selects uncorrected
%           Black-76 MtM.
%
%   OUTPUT:
%       mtm
%           Selected mark-to-market value, in EUR.

    [mtmCorrected, mtmUncorrected] = computeMtm( ...
        market, ...
        product, ...
        volsLmm, ...
        upfront, ...
        upfront);

    mtm = selectMtM( ...
        mtmCorrected, ...
        mtmUncorrected, ...
        useSmileCorrection);

end