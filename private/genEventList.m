function [e, s] = genEventList(s, runNum)

if isempty(runNum)
    [fname, pname] = uigetfile({'*.txt'}, 'Select events file');
else
    pname = pwd;
    fname = sprintf('events.map_nopev_%d.txt',runNum);
end

fid = fopen(fullfile(pname, fname)); events = fscanf(fid, '%d\n'); fclose(fid);
tr = 0.1;

evTimes = find(diff(events)>0);
evNums = events(evTimes+1);

evTimes = evTimes*tr;

if max(evNums) == 16
    startEvs = [1 5 8 12 15];
    usePromptEv = 1;
else
    startEvs = [1 4 6 9 11];
    usePromptEv = 0;
end

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

% create flanker task sequence
%   every trial should include a congruent (1)-incongruent (0) pair
%   so possible pairs are: 1-0-0, 1-0-1, 1-1-0, 0-1-0
%   distrubte these evenly for each reward level
%flankerSeqs = [1 0 0; 1 0 1; 1 1 0; 0 1 0];
flankerSeqs = [1; 0];

%   startEvs(1): high reward with flanker
%   startEvs(3): low reward with flanker
nFlankerHigh = length(find(evNums==startEvs(1)));
nFlankerLow = length(find(evNums==startEvs(3)));

% make a list of flanker sequences for each reward type
flankerSeqsHigh = Shuffle( repmat(1:size(flankerSeqs,1), [1 ceil(nFlankerHigh / size(flankerSeqs,1))]));
flankerSeqsLow = Shuffle( repmat(1:size(flankerSeqs,1), [1 ceil(nFlankerLow / size(flankerSeqs,1))]));


nMoves = 0;
e = [];
flankerHighCt = 0;
flankerLowCt = 0;
for ei = 1:length(trialStarts)
    thisEv = find(evTimes == trialStarts(ei));
    thisEvType = evNums(thisEv);
    
    e(ei).trl = ei;
    e(ei).evNum = thisEvType;
    e(ei).onset = trialStarts(ei);
    e(ei).moveOnset = [];
    e(ei).cogOnset = [];
    e(ei).fbOnset = [];
    e(ei).cogRewType = 1 + (rand>(1-s.reward.cogHighRewProb));

    
    switch thisEvType
        case startEvs(1) % high reward
            e(ei).reward = 1;
            e(ei).rewType = 2;
            e(ei).catch = 0;
            e(ei).name = 'High, Reward';
            if usePromptEv
                e(ei).moveOnset = evTimes(thisEv+1);
                e(ei).cogOnset = evTimes(thisEv+2);
                e(ei).fbOnset = evTimes(thisEv+3);
            else
                e(ei).moveOnset = e(ei).onset + s.events.promptTime;
                e(ei).cogOnset = evTimes(thisEv+1);
                e(ei).fbOnset = evTimes(thisEv+2);
            end                
            flankerHighCt = flankerHighCt + 1;
            e(ei).flankerSeq = flankerSeqs( flankerSeqsHigh(flankerHighCt), :);
            
        case startEvs(2) % high catch
            e(ei).reward = 1;
            e(ei).rewType = 2;
            e(ei).catch = 1;
            e(ei).name = 'High, Catch';
            if usePromptEv
                e(ei).moveOnset = evTimes(thisEv+1);
                e(ei).cogOnset = evTimes(thisEv+2);
            else
                e(ei).moveOnset = e(ei).onset + s.events.promptTime;
                e(ei).cogOnset = evTimes(thisEv+1);
            end  
            
        case startEvs(3) % low reward
            e(ei).reward = 1;
            e(ei).rewType = 1;
            e(ei).catch = 0;
            e(ei).name = 'Low, Reward';
            if usePromptEv
                e(ei).moveOnset = evTimes(thisEv+1);
                e(ei).cogOnset = evTimes(thisEv+2);
                e(ei).fbOnset = evTimes(thisEv+3);
            else
                e(ei).moveOnset = e(ei).onset + s.events.promptTime;
                e(ei).cogOnset = evTimes(thisEv+1);
                e(ei).fbOnset = evTimes(thisEv+2);
            end              
            flankerLowCt = flankerLowCt + 1;
            e(ei).flankerSeq = flankerSeqs( flankerSeqsLow(flankerLowCt), :);
            
            
        case startEvs(4) % low catch
            e(ei).reward = 1;
            e(ei).rewType = 1;
            e(ei).catch = 1;
            e(ei).name = 'Low, Catch';
            if usePromptEv
                e(ei).moveOnset = evTimes(thisEv+1);
                e(ei).cogOnset = evTimes(thisEv+2);
            else
                e(ei).moveOnset = e(ei).onset + s.events.promptTime;
                e(ei).cogOnset = evTimes(thisEv+1);
            end  
            
        case startEvs(5) % null
            e(ei).reward = 0;
            e(ei).rewType = 0;
            e(ei).catch = 0;
            e(ei).name = 'Null';
            if usePromptEv
                e(ei).moveOnset = evTimes(thisEv+1);
            else
                e(ei).moveOnset = e(ei).onset + s.events.promptTime;
            end              
            e(ei).cogRewType = 0;
    end
    
    

    
end

[e(:).cogRewType]
