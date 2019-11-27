% Role Playing Game (e.g. Pokemon) Task
%
% copied from MMY4 nBMSI.m
%
% USAGE:
%   RPG subj
% EXAMPLE:
%   RPG 12345 
%
%
% output is saved in behave/subj_block_time.mat and behave/csv/subj_block_time
function [w, s, map, e] = RPG(subj,w,m,s,runNum,smmode,eyetrack)

    if nargin<2
        w = [];
    end
    
    if nargin<3
        m = [];
    end
    
    if nargin<4
        s = [];
    end
    
    if nargin<5
        runNum = [];
    end
    
    if nargin<6
        smmode = [];
    end
    
    warnstate = warning('off');
    
%    [savename,dstr] = formatSaveName(subj,blocktype);
%    diary([savename '_log.txt']);

    if ~isempty(s) % save resolution so we don't reset it
        res = s.screen.res;
    else
        res = [];
    end
    
    w
    sendXdat(0);
    if isempty(w)
        InitializePsychSound;
        [w,res]=setupScreen([120 120 120], []);s.screen.res = res(3:4);
    end
    
    PsychPortAudio('Close')
    if isfield(s, 'events') && isfield(s.events, 'totalScore') % don't re-initialize
        totalScore = s.events.totalScore;
    else
        totalScore = 0;
    end

    s = getSettings(s, '', smmode); 
    s.events.totalScore = totalScore;
    
    if s.forceReopenWindow
        [w,res]=setupScreen([120 120 120], []);s.screen.res = res(3:4);
    end
    
    e = genEventList(s, runNum);
    map = initMap(s, m, length(e));
    for ei = 1:length(e)
        fprintf(1, '%d: %d %d %s\n', ei, e(ei).reward, e(ei).rewType, e(ei).name);
    end
    
%     if isempty(w)
%         [w,res]=setupScreen(s.screen.bg, s.screen.res);
%         s.screen.res = res(3:4);
% %    else
%         %s.screen.res = res;
%     end
    
    s.images.me.tex = Screen('MakeTexture', w, s.images.me.image);
    s.images.reward{1}.tex = Screen('MakeTexture', w, s.images.reward{1}.image);
    s.images.reward{2}.tex = Screen('MakeTexture', w, s.images.reward{2}.image);
    s.images.cogreward{1}.tex = Screen('MakeTexture', w, s.images.cogreward{1}.image);
    s.images.cogreward{2}.tex = Screen('MakeTexture', w, s.images.cogreward{2}.image);
    s.images.null.tex = Screen('MakeTexture', w, s.images.null.image);
    s.images.bg.tex = Screen('MakeTexture', w, s.images.bg.image);
    s.images.progress_bg.tex = Screen('MakeTexture', w, s.images.progress_bg.image);
    
    pahandle = PsychPortAudio('Open', [], [], 1, s.sounds.null.fs, 2);
    PsychPortAudio('UseSchedule', pahandle, 0);
    s.pahandle = pahandle;
    
    showCal(w, s.screen.res);

    if runNum == 1 & ~s.session.simulate
        instructions(w, s);
    end
        
    
    if ~s.session.simulate
        WaitSecs(0.5);
        scannerTrigger = 0;
    else
        scannerTrigger = 1;
        [keyIsDown, keyPressTime, keyCode] = KbCheck;
    end
    
    while ~scannerTrigger
        if s.host.isMR
            DrawFormattedText(w,'Waiting to start','center','center',[ 0 0 0 ]);
        else
            DrawFormattedText(w,'Press = to start','center','center',[ 0 0 0 ]);
        end
        
        Screen('Flip',w);
        [keyIsDown, keyPressTime, keyCode] = KbCheck;
        if strcmp( KbName(keyCode), '=+' ) | strcmp( KbName(keyCode), '=' )
            scannerTrigger = 1;
        end
    end

    % we start when the scanner sends the go ahead
    starttime = getReady(w,s.host.type);
    if s.session.simulate
        starttime = starttime - 100000;
    end
    newLoc.x = [];
    newLoc.y = [];
    prevLoc.x = [];
    prevLoc.y = [];

    fprintf(1, 'Starting run at time=%d\n\n', starttime);
    showEventTimes(e);
    
    for ei=1:length(e)


        % get settings for this trial
        trl    = e(ei).trl;
        ename  = e(ei).name;
        onset  = e(ei).onset + starttime;
        moveOnset = e(ei).moveOnset + starttime;
        cogOnset  = e(ei).cogOnset + starttime;
        fbOnset   = e(ei).fbOnset + starttime;
        
        % show map and wait for trial start time
        e(ei).map = map;
        e(ei).currentLocation = map.currentLocation;
        e(ei).times.onset = updateMap(w, s, e(ei)) - starttime;
        sendXdat(s.parallel.xdat.mapDisplay);

        while GetSecs<onset
            WaitSecs(0.001);
        end

        %e(ei)
        fprintf(1, '%.0f: Waiting for move; Expected %.2f, Actual %.2f, %s\n', GetSecs, e(ei).onset, GetSecs-starttime, e(ei).name);

        % prompt for move
        %  first, pick a new probability level
        nextpLev = ones(size(map.pLevels));
        if ei>1 
            currpLevIndex = find(map.currentProb == map.pLevels);
        else
            currpLevIndex = find(map.pMap(map.currentLocation.x, map.currentLocation.y) == map.pLevels);
        end
        
        availableProbs = [];
        for plevi = 1:length(map.pLevels)
%            if plevi ~= currpLevIndex
                if e(ei).reward==1
                    availableProbs = [availableProbs repmat(map.pLevels(plevi), [1 map.trials.maxRewarded(plevi)-map.trials.numRewarded(plevi)])];
                else
                    availableProbs = [availableProbs repmat(map.pLevels(plevi), [1 map.trials.maxUnrewarded(plevi)-map.trials.numUnrewarded(plevi)])];
                end
%            end
        end

        if isempty(availableProbs) % at the end, may have to repeat a probability level
            availableProbs = [];
            for plevi = 1:length(map.pLevels)
                if e(ei).reward==1
                    availableProbs = [availableProbs repmat(map.pLevels(plevi), [1 map.trials.maxRewarded(plevi)-map.trials.numRewarded(plevi)])];
                else
                    availableProbs = [availableProbs repmat(map.pLevels(plevi), [1 map.trials.maxUnrewarded(plevi)-map.trials.numUnrewarded(plevi)])];
                end
            end
        end            
        
        prob(1) = availableProbs( randi(length(availableProbs), 1) );
        if mod(ei,4)==0
            % exclude the probability of the first probe location
            availableProbs2 = availableProbs(find(availableProbs ~= prob(1)));
            if isempty(availableProbs2)
                availableProbs2 = availableProbs;
            end
            prob(2) = availableProbs2( randi(length(availableProbs2), 1) );
        else
            prob(2) = prob(1);
        end
        
       
        %  find squares with these prob levels
        moves = [];
        for probi = 1:length(prob)
            [moves(probi).x, moves(probi).y] = find(map.pMap == prob(probi));
        end

        %  eliminate the current square, if it's in the list
        for probi = 1:length(prob)
            validMoves = find(moves(probi).x ~= map.currentLocation.x | moves(probi).y ~= map.currentLocation.y);
            moves(probi).x = moves(probi).x(validMoves);
            moves(probi).y = moves(probi).y(validMoves);
        end
        
        %  pick 2
        same = 1;
        while same
            for probi = 1:length(prob)
                if strcmp(s.map.moveChoiceMethod, 'random')
                    squareList = 1:length(moves(probi).x);
                    [squareListShuffled, shufflei] = Shuffle(squareList);
                    moves(probi).x = moves(probi).x(shufflei);
                    moves(probi).y = moves(probi).y(shufflei);
                elseif strcmp(s.map.moveChoiceMethod, 'nearest')
                    d = sqrt( (moves(probi).x - map.currentLocation.x).^2 + (moves(probi).y - map.currentLocation.y).^2 );
                    [d_sorted, sorti] = sort(d,1,'ascend');
                    moves(probi).x = moves(probi).x(sorti);
                    moves(probi).y = moves(probi).y(sorti);
                    
                    if prob(1) == prob(2) & probi == 2  % so that we don't pick the same square both times
                        moves(probi).x = moves(probi).x(2:end);
                        moves(probi).y = moves(probi).y(2:end);
                    end
                        
                end
            end
            if moves(1).x(1) == moves(2).x(1) & moves(1).y(1) == moves(2).y(1)
                same = 1;
            else
                same = 0;
            end
        end
            
        
        moveOpts = [];
        for i = 1:s.moves.numChoices
            moveOpts(i).value = i;
            moveOpts(i).x = moves(i).x(1);
            moveOpts(i).y = moves(i).y(1);
            moveOpts(i).pLev = map.pMap(moveOpts(i).x, moveOpts(i).y);
        end
        
        
        %  re-sort so that "1" corresponds to the left-most (or top-most) one
        xs = [moveOpts(:).x];
        ys = [moveOpts(:).y];
        [new sortedMovesi] = sortrows([xs' ys'], [1 2]);
        moveOpts = moveOpts(sortedMovesi);
        for i = 1:s.moves.numChoices
            moveOpts(i).value = i; % relabel
        end
        
        % update event log and show move options
        e(ei).map = map;
        e(ei).moveOpts = moveOpts;
        e(ei).times.prompt = updateMap(w, s, e(ei), [], moveOpts) - starttime;
        sendXdat(s.parallel.xdat.mapChoices);

        % wait for move choice
        keyIsDown = 0;
        validResponse = 0;
        validKeys = s.keys.finger;
        keyPressName = '';
        
        while (~keyIsDown | ~validResponse) & GetSecs<(moveOnset-0.1)
            [keyIsDown, keyPressTime, keyCode] = KbCheck;
            validResponse = ~isempty(find(keyCode)) && any(find(keyCode,1,'first')==validKeys);
        end
        
        
        if validResponse
            pushedkey=find(keyCode,1,'first'),
            pushedidx=find(pushedkey==s.keys.finger),
            s.keys.string,
            keyPressName = s.keys.string{pushedidx};
            if strcmp(keyPressName, 'Esc') %find(keyCode,1,'first')==s.keys.finger(5)
                break;
            end
            resp = str2double(keyPressName); %find(find(keyCode,1,'first')==s.keys.finger(1:s.moves.numChoices));
            e(ei).times.moveResponse = keyPressTime - starttime;
            sendXdat(s.parallel.xdat.madeMove);
        else
            resp = [];
        end
        
        if isempty(resp)
            resp = randi([1 length(moveOpts)],1);
            e(ei).times.moveResponse = NaN;
        end

        prevLoc.x = map.currentLocation.x;
        prevLoc.y = map.currentLocation.y;
        
        %  update the count for this probability level
        map.currentProb = moveOpts(resp).pLev;
        newpLevi = find(map.currentProb == map.pLevels);
        e(ei).currentProb = map.currentProb;
        if e(ei).reward
            map.trials.numRewarded(newpLevi) = map.trials.numRewarded(newpLevi)+1;
        else
            map.trials.numUnrewarded(newpLevi) = map.trials.numUnrewarded(newpLevi)+1;
        end

        
        % display highlighted map
        newLoc.x = moveOpts(resp).x;
        newLoc.y = moveOpts(resp).y;
        updateMap(w, s, e(ei), [newLoc.x newLoc.y]);
        
        % wait for move onset
        while GetSecs < moveOnset
            WaitSecs(0.001);
        end
        
        % move
        map.startLocation = map.currentLocation;
        
        map.currentLocation.x = newLoc.x;
        map.currentLocation.y = newLoc.y;
        e(ei).map = map;
        e(ei).times.move = move(w, s, e(ei)) - starttime; %updateMap(w, s, e(ei));
        sendXdat(s.parallel.xdat.mapReward);
        fprintf(1, '%.0f: Move, showing reward; Expected %.2f, Actual %.2f, %s\n', GetSecs, e(ei).moveOnset, e(ei).times.move, e(ei).name);
        map = e(ei).map;
        e(ei).mapPoints =  s.reward.points(e(ei).rewType+1);
        
        switch e(ei).rewType
            case 2
                e(ei).times.move_high = e(ei).times.move;
            case 1
                e(ei).times.move_low = e(ei).times.move;
            case 0
                e(ei).times.move_null = e(ei).times.move;
        end
        
        % update map history
        firstNaN = find(isnan(squeeze(map.visitOutcomes(map.currentLocation.x, map.currentLocation.y,:))),1,'first');
        map.visitOutcomes(map.currentLocation.x, map.currentLocation.y,firstNaN) = e(ei).rewType;

        if e(ei).reward
            
            % wait for cog onset
            while GetSecs < cogOnset
                WaitSecs(0.001);
            end
            
            
            % purge eye tracker cache before showing fixation
            if ~isempty(s.serial.handle)
                IOPort('Purge', s.serial.handle);
            end
            
            % show bonus round screen
            bonus_round(w, s, e(ei), ~strcmp(smmode, 'smcontrol'));
            if ~s.session.simulate
                WaitSecs(1.0);
            end
            
            % show fixation
            sendXdat(s.parallel.xdat.cogFixation);
            e(ei).times.cogFixation = event_Fix(w, s, e(ei), 0) - starttime;
            fprintf(1, '%.0f: Fixation; Expected %.2f, Actual %.2f, %s\n', GetSecs, e(ei).cogOnset, e(ei).times.cogFixation, e(ei).name);
            if ~s.session.simulate
                WaitSecs(3.0);
            end           

            switch e(ei).cogRewType
                case 2
                    e(ei).times.cogFixation_high = e(ei).times.cogFixation;
                case 1
                    e(ei).times.cogFixation_low = e(ei).times.cogFixation;
            end

           % bonusesNeeded = s.events.numExtraBonusNeeded
            if e(ei).catch
                
%                event_Fix(w, s, e(ei));
%                oldTextSize=Screen('TextSize', w, 64);

                if s.events.numExtraBonusNeeded>0
                    showBonus = 1;
                    s.events.numExtraBonusNeeded = s.events.numExtraBonusNeeded - 1;
                else
                    showBonus = 0;
                end

                waitUntil = GetSecs + 3;
                if ei < length(e)
                    waitUntil = e(ei+1).onset - 1.0 + starttime;
                end
                
                if s.session.simulate
                    waitUntil = GetSecs -100000;
                end
                

                while GetSecs < (waitUntil - 1.5*showBonus)
                    WaitSecs(0.001);
                end
%                DrawFormattedText(w, sprintf('Free!\n+%d', s.reward.points(e(ei).rewType)), 'center', 'center', ...
%                        s.flanker.colors.correct);
%                [v,onset] = Screen('Flip',w);
%                Screen('TextSize', w, oldTextSize);

%                WaitSecs(0.5);

                if ~isempty(s.serial.handle)
                    [e(ei).eyedata.fixation.raw, e(ei).eyedata.fixation.when, e(ei).eyedata.fixation.errmsg] = IOPort('Read', s.serial.handle);
                end
                
                if showBonus
                    fbString = 'Bonus!';
                    fbColor = s.anti.colors.correct;
                    snd = s.sounds.cogreward{e(ei).cogRewType};
                    e(ei).cogPoints =  s.reward.points(e(ei).rewType);
                else
                    fbString = 'Catch';
                    fbColor = s.anti.colors.text;
                    snd = s.sounds.null;
                    e(ei).cogPoints = 0;
                end
                
                e(ei).times.catchFeedback = bonus_round(w, s, e(ei), showBonus, fbString, fbColor) - starttime;

                switch e(ei).cogRewType
                    case 2
                        e(ei).times.catchFeedback_high = e(ei).times.catchFeedback;
                    case 1
                        e(ei).times.catchFeedback_low = e(ei).times.catchFeedback;
                end
                
%                     DrawFormattedText(w, sprintf('Bonus!') , 'center', 'center', ...
%                                     s.flanker.colors.correct);
                

                % play sounds
                if s.sounds.useSounds% & ~isempty(snd)
                    %pahandle = PsychPortAudio('Open', [], [], 1, snd.fs, 2);
                    %PsychPortAudio('UseSchedule', pahandle, 0);
                    [underflow, nextSampleStartIndex, nextSampleETASecs] = PsychPortAudio('FillBuffer', pahandle, snd.aud);
                    PsychPortAudio('Start', pahandle, [], 0, 1);

                    % Wait for end of playback, then stop:
                    PsychPortAudio('Stop', pahandle, 1);

                    % Delete all dynamic audio buffers:
                    PsychPortAudio('DeleteBuffer');

                    % Close audio device, shutdown driver:
                    %PsychPortAudio('Close');
                end
                
                while GetSecs < waitUntil
                    WaitSecs(0.001);
                end

            else
                
                % grab eye tracking data during fixation
                %   this will also empty the cache before doing the anti
                %   task, so that the next read should be just the cog task
                if ~isempty(s.serial.handle)
                    [e(ei).eyedata.fixation.raw, e(ei).eyedata.fixation.when, e(ei).eyedata.fixation.errmsg] = IOPort('Read', s.serial.handle);

                    % calculate x,y during fixation
                    %   use this as a baseline for determining subsequent eye
                    %   movements.  base it on the last half of the fixation
                    %   time (by which time hopefully they're actually
                    %   fixating).
                    [fixX, fixY] = decodeEyeData(e(ei).eyedata.fixation.raw, s.serial.xbytes, s.serial.ybytes, s.serial.lineLength);

                    try
                        meanX = mean(fixX(round(length(fixX)/2):end));
                        meanY = mean(fixY(round(length(fixY)/2):end));
                        stdX = std(fixX(round(length(fixX)/2):end));
                        stdY = std(fixY(round(length(fixY)/2):end));
                    catch
                        meanX = NaN; meanY = NaN;
                        stdX = NaN; stdY = NaN;
                    end
                    
                    e(ei).eyedata.fixation.meanX = meanX;
                    e(ei).eyedata.fixation.meanY = meanY;
                    e(ei).eyedata.fixation.stdX = stdX;
                    e(ei).eyedata.fixation.stdY = stdY;
                end
                
                if ~isempty(s.serial.handle)
                    IOPort('Purge', s.serial.handle);
                end
                
                startEyeTracking = GetSecs;
                sendXdat(s.parallel.xdat.cogTask);
                [e(ei).cogRes, e(ei).times.cogOnset] = anti(w, s, e(ei));
%                e(ei).times.cogResponse = e(ei).cogRes.cogRespTime - starttime;
                e(ei).times.cogOnset = e(ei).times.cogOnset - starttime;
                
                switch e(ei).cogRewType
                    case 2
                        e(ei).times.cogOnset_high = e(ei).times.cogOnset;
                    case 1
                        e(ei).times.cogOnset_low = e(ei).times.cogOnset;
                end
                
                % show feedback
                while GetSecs < fbOnset
                    WaitSecs(0.001);
                end
                endEyeTracking = GetSecs;
                
                % grab eye tracking data during anti
                if ~isempty(s.serial.handle)
                    [e(ei).eyedata.cog.raw, e(ei).eyedata.cog.when, e(ei).eyedata.cog.errmsg] = IOPort('Read', s.serial.handle);
                    [e(ei).eyedata.cog.x, e(ei).eyedata.cog.y] = decodeEyeData(e(ei).eyedata.cog.raw, s.serial.xbytes, s.serial.ybytes, s.serial.lineLength);

                    e(ei).eyedata.cog.duration = endEyeTracking - startEyeTracking;
                    
                    % figure out if they made a correct eye movement, and when
%                    e(ei).cogRes.eyeMoveInd = find( abs(e(ei).eyedata.cog.x - meanX) / stdX > 4, 1, 'first'); % first time point when x-coordinate is more than 3 standard deviations from baseline
                    e(ei).cogRes.eyeMoveInd = find( (e(ei).eyedata.cog.x < s.anti.leftThresh) | (e(ei).eyedata.cog.x > s.anti.rightThresh), 1, 'first');

                    % convert to time

                    % figure out direction; -1 = left, +1 = right
                    e(ei).cogRes.eyeMoveDirection = sign( e(ei).eyedata.cog.x(e(ei).cogRes.eyeMoveInd) - s.anti.center );

                    % set outputs
                    e(ei).cogRes.respEval = (e(ei).cogRes.targetSide == -1*e(ei).cogRes.eyeMoveDirection);
                    
                    e(ei).cogRes.rt = e(ei).cogRes.eyeMoveInd / length(e(ei).eyedata.cog.x); %keyDownTime - cogDisplayTime;               
                     
                    
                else
                    e(ei).cogRes.respEval = 1;
                end


                oldTextSize=Screen('TextSize', w, 64);
                if strcmp(smmode, 'smcontrol')
                        DrawFormattedText(w, '######', 'center', 'center', ...
                                s.map.colors.text);
                        e(ei).cogPoints = 0;
                        snd = s.sounds.null;
                else
                    if (~isempty(e(ei).cogRes.respEval) && e(ei).cogRes.respEval) | ~eyetrack
                        bonus_round(w, s, e(ei), 1, 'Bonus!', s.anti.colors.correct);
%                         DrawFormattedText(w, sprintf('Bonus!') , 'center', 'center', ...
%                                     s.flanker.colors.correct);
                        e(ei).cogPoints =  s.reward.points(e(ei).cogRewType+1);
                        snd = s.sounds.cogreward{e(ei).cogRewType};
                    else
	                bonus_round(w, s, e(ei), 0, sprintf('Incorrect\nNo bonus'), s.anti.colors.text);
%                         DrawFormattedText(w, 'Incorrect\nNo bonus', 'center', 'center', ...
%                                 s.map.colors.text);
                        e(ei).cogPoints = 0;
                        snd = s.sounds.beep;
                        s.events.numExtraBonusNeeded = s.events.numExtraBonusNeeded + 1;
                    end
                end
                e(ei).times.feedback = GetSecs - starttime; % Screen('Flip',w) - starttime;
                sendXdat(s.parallel.xdat.cogFeedback);

                switch e(ei).cogRewType
                    case 2
                        e(ei).times.feedback_high = e(ei).times.feedback;
                    case 1
                        e(ei).times.feedback_low = e(ei).times.feedback;
                end
                
                % play sounds
                if s.sounds.useSounds% & ~isempty(snd)
                    %pahandle = PsychPortAudio('Open', [], [], 1, snd.fs, 2);
                    %PsychPortAudio('UseSchedule', pahandle, 0);
                    [underflow, nextSampleStartIndex, nextSampleETASecs] = PsychPortAudio('FillBuffer', pahandle, snd.aud);
                    PsychPortAudio('Start', pahandle, [], 0, 1);

                    % Wait for end of playback, then stop:
                    PsychPortAudio('Stop', pahandle, 1);

                    % Delete all dynamic audio buffers:
                    PsychPortAudio('DeleteBuffer');

                    % Close audio device, shutdown driver:
                    %PsychPortAudio('Close');
                end
                
                fprintf(1, '%.0f: Presenting feedback; Expected %.2f, Actual %.2f, %s\n', GetSecs, e(ei).fbOnset, e(ei).times.feedback, e(ei).name);
                if ~s.session.simulate
                    while GetSecs < e(ei).times.feedback + 1.0
                        WaitSecs(0.01);
                    end
                end
                Screen('TextSize', w, oldTextSize);
            
            end
           
        else
            
            if ~s.session.simulate
                WaitSecs(1.0);
            end
            
        end
        
       
            
    end
    
    %maptestResults = [];
    finalMaptestResults = [];
%    save(sprintf('results/results_%s_%d.mat', subj, runNum), 's','map','e','maptestResults','finalMaptestResults','starttime','runNum');
    save(sprintf('results/results_%s_%d.mat', subj, runNum), 's','map','e','finalMaptestResults','starttime','runNum');

    spatialTestEv = e(ei);
    spatialTestEv.map.currentLocation.x = [];
    
    if ~strcmp(smmode, 'smcontrol')
        showProgress(w, s, e, map, runNum)
        s.events.totalScore = s.events.totalScore + sum([e(:).cogPoints]) + sum([e(:).mapPoints]);
        s.events.totalScore
    end
        
    
    if ~s.session.simulate% && runNum==6
    
        
%         DrawFormattedText(w, ...
%             ['Now we''ll take a quick break.\n\n' ...
%              'For each of the squares you?ll be shown, indicate\n\n' ...
%              'which one you''ve gotten more rewards from so far.\n\n\n\n' ...
%              '(Press any key to start)'], ...
%             'center','center',[ 1 1 1 ]*255);
%         
%         Screen('Flip',w);
%         WaitSecs(.5);
%         [secs, keyCode, deltaSecs] =KbWait;
% 
%         updateMap(w, s, spatialTestEv);
%         WaitSecs(2.0);
% %        maptestResults = maptest(w, s, 5, map, 'matchedVisits');
%         maptestResults = maptest(w, s, 10, map, 'hybrid');

        if ~isempty(runNum) & runNum == 1%s.session.maxRuns
            DrawFormattedText(w, ...
                ['Good job!  Now we''ll see how well you learned the map.\n\n' ...
                 'For each of the squares you''ll be shown, indicate\n\n' ...
                 'which one you gave you more rewards.\n\n\n\n' ...
                 '(Press any key to start)'], ...
                'center','center',[ 1 1 1 ]*255);
            Screen('Flip', w);
            KbWait;
            finalMaptestResults = maptest(w, s, 50, map, 'random');
        else
            finalMaptestResults = [];
        end

    else
    %    maptestResults = [];
        finalMaptestResults = [];
    end
    
    save(sprintf('results/results_%s_%d.mat', subj, runNum), 's','map','e','finalMaptestResults','starttime','runNum');
    % shut it all down
    
    PsychPortAudio('Close');
    if runNum == s.session.maxRuns
        closedown();
    end


    warning(warnstate);
end
