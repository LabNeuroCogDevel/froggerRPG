function showEventTimes(e)

rewStr = {'None','Low ','High'};
cogStr = {'    ','Null','Rew '};
catchStr = {'     ','Catch'};

fprintf(1, '     Map  Cog        \t   Hash   Prompt     Move    Bonus Feedback\n');
for ei = 1:length(e)
    
    fprintf(1, '%2d: (%s %s %s)\t', ei, rewStr{1 + e(ei).rewType}, cogStr{1 + e(ei).hascog * e(ei).cogRewType}, catchStr{1 + e(ei).hascog*e(ei).catch});
    
    if ~isempty(e(ei).hashOnset)
        fprintf(1, '% 7.2f  ', e(ei).hashOnset);
    end

    if ~isempty(e(ei).promptOnset)
        fprintf(1, '% 7.2f  ', e(ei).promptOnset);
    end
    
    if ~isempty(e(ei).moveOnset)
        fprintf(1, '% 7.2f  ', e(ei).moveOnset);
    end
    
    if ~isempty(e(ei).cogOnset)
        fprintf(1, '% 7.2f  ', e(ei).cogOnset);
    end
    
    if ~isempty(e(ei).fbOnset)
        fprintf(1, '% 7.2f  ', e(ei).fbOnset);
    end    
    
    fprintf(1, '\n');
end