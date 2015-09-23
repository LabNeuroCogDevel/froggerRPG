function write1dFiles(subj)

    eventNames = {'onset','prompt','moveResponse','move','move_high','move_low','move_null','cogFixation','cogFixation_high','cogFixation_low','cogOnset','cogOnset_high','cogOnset_low','feedback','feedback_high','feedback_low','catchFeedback','catchFeedback_high','catchFeedback_low'};
    for evi = 1:length(eventNames)
        if ~exist(sprintf('1d/%s', subj))
            mkdir(sprintf('1d/%s', subj));
        end
        fid.(eventNames{evi}) = fopen(sprintf('1d/%s/%s.1D', subj, eventNames{evi}), 'w');
    end
    
    for i = 1:6
        res(i) = load(sprintf('results/results_%s_%d.mat', subj, i));
        e = res(i).e;
        
        for ei = 1:length(e)
            evs = fieldnames(e(ei).times);
            for evi = 1:length(evs)
                if ~isfield(fid, evs{evi})
                    error('No file for %s', evs{evi});
                end
                if ~isnan(e(ei).times.(evs{evi}))
                    fprintf(fid.(evs{evi}), '%.1f\t', e(ei).times.(evs{evi}));
                end
            end
        end
        
        for evi = 1:length(eventNames)
            fprintf(fid.(eventNames{evi}), '\n');
        end
    end

    for evi = 1:length(eventNames)
        fclose(fid.(eventNames{evi}));
    end

    
    
    for evi = 1:length(eventNames)
        disp(eventNames{evi});
        type(sprintf('1d/%s/%s.1D', subj, eventNames{evi}))
    end    
end