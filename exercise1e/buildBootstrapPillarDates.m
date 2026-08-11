function pillarDates = buildBootstrapPillarDates(curveDatesSet)
%BUILDBOOTSTRAPPILLARDATES Build bootstrap pillar dates for coarse shocks.
%
%   pillarDates = buildBootstrapPillarDates(curveDatesSet)
%
%   extracts the bootstrap pillar dates used to build the coarse-grained
%   rate shocks.
%
%   The pillar set is composed of:
%
%       - first 3 deposit maturities;
%       - first 7 futures end dates;
%       - swap maturities from the second quoted swap onward.
%
%   INPUT:
%       curveDatesSet
%           Struct containing bootstrap instrument dates:
%               curveDatesSet.depos
%               curveDatesSet.futures
%               curveDatesSet.swaps
%
%   OUTPUT:
%       pillarDates
%           Column vector of datetime values used as shock timetable row
%           times.

    nDepos = 3;
    nFutures = 7;

    depositDates = datetime( ...
        curveDatesSet.depos(1:nDepos), ...
        'ConvertFrom', ...
        'datenum');

    futuresEndDates = datetime( ...
        curveDatesSet.futures(1:nFutures, 2), ...
        'ConvertFrom', ...
        'datenum');

    swapDates = datetime( ...
        curveDatesSet.swaps(2:end), ...
        'ConvertFrom', ...
        'datenum');

    pillarDates = [
        depositDates(:)
        futuresEndDates(:)
        swapDates(:)
    ];

end