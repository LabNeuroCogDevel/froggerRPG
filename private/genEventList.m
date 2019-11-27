function [e, s] = genEventList(s, runNum)

if isempty(runNum)
    [fname, pname] = uigetfile({'*.txt'}, 'Select events file');
else
    pname = pwd;
    fname = sprintf('events.map_allbonus_revised3_%d.txt',runNum);
end

%%
fid = fopen(fullfile(pname, fname)); events = fscanf(fid, '%d\n'); fclose(fid);
tr = 0.1;

evTimes = find(diff(events)>0);
evNums = events(evTimes+1);

evTimes = evTimes*tr;


usePromptEv = 1;
useHashEv = 1;
startEvs = [ 1:2:30]; 
evNames =  {'mHashHighCogRew',      'mPromptHighCogRew',  ...
            'mHashHighCogRewCatch', 'mPromptHighCogRewCatch', ...
            'mHashHighCogNull',     'mPromptHighCogNull', ...
            'mHashHighCogNullCatch','mPromptHighCogNullCatch', ...
            'mHashHighNoCog',       'mPromptHighNoCog', ...
            'mHashLowCogRew',       'mPromptLowCogRew', ...
            'mHashLowCogRewCatch',  'mPromptLowCogRewCatch',  ...
            'mHashLowCogNull',      'mPromptLowCogNull', ...
            'mHashLowCogNullCatch', 'mPromptLowCogNullCatch', ...
            'mHashLowNoCog',        'mPromptLowNoCog', ...
            'mHashNullCogRew',      'mPromptNullCogRew', ...
            'mHashNullCogRewCatch', 'mPromptNullCogRewCatch', ...
            'mHashNullCogNull',     'mPromptNullCogNull', ...
            'mHashNullCogNullCatch','mPromptNullCogNullCatch', ...
            'mHashNullNoCog',       'mPromptNullNoCog'};

%for i = 1:length(evNames); fprintf(1, '%d: %s\n', i, evNames{i}); end

itis = [];
for i = 1:length(evTimes)
    if any(evNums(i)==startEvs)
        if i>1
            itis(end+1) = evTimes(i) - (evTimes(i-1)+3+7*(any(evNums(i-1)==[2 4 6 8 12 14 16 18 22 24 26 28])));
        end
        fprintf(1, '\n');
    end
    fprintf(1, '%.2f: %d %s\n', evTimes(i), evNums(i), evNames{evNums(i)});
end

%%
trialStarts = [];
for ei = 1:length(evNums)
    if any(evNums(ei) == startEvs)
%           -stim_labels  pHigh mHigh cogHigh fbHigh \
%                         pHighCatch mHighCatch cogHighCatch \
%                         pLow mLow cogLow fbLow \
%                         pLowCatch mLowCatch cogLowCatch \
%                         pNull mNull \
        trialStarts(end+1) = evTimes(ei);
    end
end


nMoves = 0;
e = [];

for ei = 1:length(trialStarts)
    thisEv = find(evTimes == trialStarts(ei));
    thisEvType = evNums(thisEv);
    
    e(ei).trl = ei;
    e(ei).evNum = thisEvType;
    e(ei).onset = trialStarts(ei);
    e(ei).moveOnset = [];
    e(ei).cogOnset = [];
    e(ei).fbOnset = [];
    %e(ei).cogRewType = 1 + (rand>(1-s.reward.cogHighRewProb));

    e(ei).hashOnset = evTimes(thisEv)+1.0;  % steal a little time from the hashes to get more baseline
    e(ei).promptOnset = evTimes(thisEv+1);
    e(ei).moveOnset = e(ei).promptOnset + s.events.promptTime;

    switch thisEvType
        case startEvs(1) % high, cog rew
            e(ei).reward = 1;
            e(ei).rewType = 2;
            e(ei).catch = 0;
            e(ei).hascog = 1;
            e(ei).name = 'High, Cog Reward';

            e(ei).cogOnset = e(ei).moveOnset + s.events.mapRewardTime; % really, cog fixation
            e(ei).fbOnset = e(ei).cogOnset + s.events.bonusRoundTime + s.events.cogFixTime + s.events.cogExecTime;
            e(ei).cogRewType = 2;

        case startEvs(2) % high, cog rew, catch
            e(ei).reward = 1;
            e(ei).rewType = 2;
            e(ei).catch = 1;
            e(ei).hascog = 1;
            e(ei).name = 'High, Cog Reward, Catch';

            e(ei).cogOnset = e(ei).moveOnset + s.events.mapRewardTime; % really, cog fixation
            e(ei).fbOnset = e(ei).cogOnset + s.events.bonusRoundTime + s.events.cogFixTime + s.events.cogExecTime;
            e(ei).cogRewType = 2;

        case startEvs(3) % high, cog null
            e(ei).reward = 1;
            e(ei).rewType = 2;
            e(ei).catch = 0;
            e(ei).hascog = 1;
            e(ei).name = 'High, Cog Null';

            e(ei).cogOnset = e(ei).moveOnset + s.events.mapRewardTime; % really, cog fixation
            e(ei).fbOnset = e(ei).cogOnset + s.events.bonusRoundTime + s.events.cogFixTime + s.events.cogExecTime;
            e(ei).cogRewType = 1;

        case startEvs(4) % high, cog null, catch
            e(ei).reward = 1;
            e(ei).rewType = 2;
            e(ei).catch = 1;
            e(ei).hascog = 1;
            e(ei).name = 'High, Cog Null, Catch';

            e(ei).cogOnset = e(ei).moveOnset + s.events.mapRewardTime; % really, cog fixation
            e(ei).fbOnset = e(ei).cogOnset + s.events.bonusRoundTime + s.events.cogFixTime + s.events.cogExecTime;    
            e(ei).cogRewType = 1;

        case startEvs(5) % high, no cog
            e(ei).reward = 1;
            e(ei).rewType = 2;
            e(ei).catch = 0;
            e(ei).hascog = 0;
            e(ei).name = 'High, No cog';

            e(ei).cogRewType = 0;    

        case startEvs(6) % low, cog rew
            e(ei).reward = 1;
            e(ei).rewType = 1;
            e(ei).catch = 0;
            e(ei).hascog = 1;
            e(ei).name = 'Low, Cog Reward';

            e(ei).cogOnset = e(ei).moveOnset + s.events.mapRewardTime; % really, cog fixation
            e(ei).fbOnset = e(ei).cogOnset + s.events.bonusRoundTime + s.events.cogFixTime + s.events.cogExecTime;
            e(ei).cogRewType = 2;

        case startEvs(7) % low, cog rew, catch
            e(ei).reward = 1;
            e(ei).rewType = 1;
            e(ei).catch = 1;
            e(ei).hascog = 1;
            e(ei).name = 'Low, Cog Reward, Catch';

            e(ei).cogOnset = e(ei).moveOnset + s.events.mapRewardTime; % really, cog fixation
            e(ei).fbOnset = e(ei).cogOnset + s.events.bonusRoundTime + s.events.cogFixTime + s.events.cogExecTime;   
            e(ei).cogRewType = 2;

        case startEvs(8) % low, cog null
            e(ei).reward = 1;
            e(ei).rewType = 1;
            e(ei).catch = 0;
            e(ei).hascog = 1;
            e(ei).name = 'Low, Cog Null';

            e(ei).cogOnset = e(ei).moveOnset + s.events.mapRewardTime; % really, cog fixation
            e(ei).fbOnset = e(ei).cogOnset + s.events.bonusRoundTime + s.events.cogFixTime + s.events.cogExecTime;
            e(ei).cogRewType = 1;

        case startEvs(9) % low, cog null, catch
            e(ei).reward = 1;
            e(ei).rewType = 1;
            e(ei).catch = 1;
            e(ei).hascog = 1;
            e(ei).name = 'Low, Cog Null, Catch';

            e(ei).cogOnset = e(ei).moveOnset + s.events.mapRewardTime; % really, cog fixation
            e(ei).fbOnset = e(ei).cogOnset + s.events.bonusRoundTime + s.events.cogFixTime + s.events.cogExecTime;    
            e(ei).cogRewType = 1;

        case startEvs(10) % low, no cog
            e(ei).reward = 1;
            e(ei).rewType = 1;
            e(ei).catch = 0;
            e(ei).hascog = 0;
            e(ei).name = 'Low, No cog';

            e(ei).cogRewType = 0;            

        case startEvs(11) % null, cog rew
            e(ei).reward = 0;
            e(ei).rewType = 0;
            e(ei).catch = 0;
            e(ei).hascog = 1;
            e(ei).name = 'Null, Cog Reward';

            e(ei).cogOnset = e(ei).moveOnset + s.events.mapRewardTime; % really, cog fixation
            e(ei).fbOnset = e(ei).cogOnset + s.events.bonusRoundTime + s.events.cogFixTime + s.events.cogExecTime;
            e(ei).cogRewType = 2;

        case startEvs(12) % null, cog rew, catch
            e(ei).reward = 0;
            e(ei).rewType = 0;
            e(ei).catch = 0;
            e(ei).hascog = 1;
            e(ei).name = 'Null, Cog Reward, Catch';

            e(ei).cogOnset = e(ei).moveOnset + s.events.mapRewardTime; % really, cog fixation
            e(ei).fbOnset = e(ei).cogOnset + s.events.bonusRoundTime + s.events.cogFixTime + s.events.cogExecTime;   
            e(ei).cogRewType = 2;

        case startEvs(13) % null, cog null
            e(ei).reward = 0;
            e(ei).rewType = 0;
            e(ei).catch = 0;
            e(ei).hascog = 1;
            e(ei).name = 'Null, Cog Null';

            e(ei).cogOnset = e(ei).moveOnset + s.events.mapRewardTime; % really, cog fixation
            e(ei).fbOnset = e(ei).cogOnset + s.events.bonusRoundTime + s.events.cogFixTime + s.events.cogExecTime;
            e(ei).cogRewType = 1;

        case startEvs(14) % null, cog null, catch
            e(ei).reward = 0;
            e(ei).rewType = 0;
            e(ei).catch = 0;
            e(ei).hascog = 1;
            e(ei).name = 'Null, Cog Null, Catch';

            e(ei).cogOnset = e(ei).moveOnset + s.events.mapRewardTime; % really, cog fixation
            e(ei).fbOnset = e(ei).cogOnset + s.events.bonusRoundTime + s.events.cogFixTime + s.events.cogExecTime;    
            e(ei).cogRewType = 1;

        case startEvs(15) % null, no cog
            e(ei).reward = 0;
            e(ei).rewType = 0;
            e(ei).catch = 1;
            e(ei).hascog = 0;
            e(ei).name = 'Null, No cog';

            e(ei).cogRewType = 0;            

    end

    
end

%showEventTimes(e)
