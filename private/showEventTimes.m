function showEventTimes(e)

rewStr = {'Rew','NoR'};
catchStr = {'Catch','+Anti','     '};

for ei = 1:length(e)
    
    fprintf(1, '%2d: (%s %s)\t', ei, rewStr{2-e(ei).reward}, catchStr{e(ei).reward*(2-e(ei).catch) + 3*(e(ei).reward==0)});
    
    if ~isempty(e(ei).onset)
        fprintf(1, '%.2f  ', e(ei).onset);
    end
    
    if ~isempty(e(ei).moveOnset)
        fprintf(1, '%.2f  ', e(ei).moveOnset);
    end
    
    if ~isempty(e(ei).cogOnset)
        fprintf(1, '%.2f  ', e(ei).cogOnset);
    end
    
    if ~isempty(e(ei).fbOnset)
        fprintf(1, '%.2f  ', e(ei).fbOnset);
    end    
    
    fprintf(1, '\n');
end