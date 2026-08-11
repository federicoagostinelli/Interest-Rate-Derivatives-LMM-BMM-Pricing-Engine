function [bucketDates, bucketNames] = getBootstrapBucketPillars(datesSet)
%GETBOOTSTRAPBUCKETPILLARS Return bootstrap pillars used for bucket DV01.
%
%   Same ordering as bootstrapShocked:
%       deposits : depos(1:3)
%       futures  : futures(1:7, 2)
%       swaps    : swaps(2:end)

    deposDates   = ensureDatetime(datesSet.depos);
    futuresDates = ensureDatetime(datesSet.futures);
    swapDates    = ensureDatetime(datesSet.swaps);

    nDepos = 3;
    nFutures = 7;

    deposDatesUsed = deposDates(1:nDepos);
    futuresEndDatesUsed = futuresDates(1:nFutures, 2);
    swapDatesUsed = swapDates(2:end);

    bucketDates = [
        deposDatesUsed(:)
        futuresEndDatesUsed(:)
        swapDatesUsed(:)
    ];

    nBuckets = numel(bucketDates);

    bucketNames = strings(nBuckets, 1);

    for i = 1:nDepos
        bucketNames(i) = sprintf('Deposit %d', i);
    end

    for i = 1:nFutures
        bucketNames(nDepos + i) = sprintf('Future %d', i);
    end

    for i = 1:numel(swapDatesUsed)
        bucketNames(nDepos + nFutures + i) = sprintf('Swap %d', i + 1);
    end

end