function res = flanker(w, s, e, forceCongruent, forceCentralDir)
    
    if nargin < 4
        forceCongruent = [];
    end
    
    if nargin < 5
        forceCentralDir = [];
    end
    symbols = '<>';

    if isempty(forceCongruent)
        res.congruent = rand>0.5;
    else
        res.congruent = forceCongruent;
    end
    
    if isempty(forceCentralDir)
        res.centralDir = rand>0.5;
    else
        res.centralDir = forceCentralDir;
    end
    
    drawCross(w,s.fix.color);
    [v,onset] = Screen('Flip',w);
    if ~s.session.simulate
        WaitSecs(1.0);
    end    
    
    for triali = 1:length(res.congruent)

        if res.congruent(triali)
            res.flankerDir(triali) = res.centralDir(triali);
        else
            res.flankerDir(triali) = 1-res.centralDir(triali);
        end


        centralDiri = res.centralDir(triali) + 1;
        flankerDiri = res.flankerDir(triali) + 1;

        if res.congruent(triali) <= 1
            stimString = sprintf('%s%s%s%s%s', symbols(flankerDiri), symbols(flankerDiri), symbols(centralDiri), symbols(flankerDiri), symbols(flankerDiri));
        else % random flankers
            stimString = sprintf('%s%s%s%s%s', symbols(1+(rand>0.5)), symbols(1+(rand>0.5)), symbols(centralDiri), symbols(1+(rand>0.5)), symbols(1+(rand>0.5)));
        end

        oldTextSize=Screen('TextSize', w, 48);
        cogDisplayTime = GetSecs;

        if s.session.simulate
            cogDisplayTime = cogDisplayTime - 100000;
        end

        keyIsDown = 0; validResponse = 0; keyDownTime = 0; keyCode = [];
        done = 0;
        while ~done
            if ~isempty(s.flanker.maxRespTime)
                % if there's a time specified, loop until time is up
                done = ~(GetSecs<cogDisplayTime+s.flanker.maxRespTime);
            else
                % no time specified, wait for valid response
                done = validResponse;
            end


            if GetSecs < cogDisplayTime+s.flanker.displayTime
                DrawFormattedText(w, stimString, 'center', 'center', ...
                        s.flanker.colors.text);
                Screen('Flip',w);
            else
                if ~keyIsDown | ~validResponse
                    drawCross(w,s.fix.color);
                end
                Screen('Flip',w);
            end

            if ~keyIsDown | ~validResponse
                [keyIsDown, keyDownTime, keyCode] = KbCheck;
                validResponse = ~isempty(find(keyCode)) && any(find(keyCode,1,'first')==s.keys.finger(1:2));
            end
        end

        if ~validResponse
        %    'no response given'
            res.resp(triali) = -1;
        else
            res.resp(triali) = find(find(keyCode,1,'first')==s.keys.finger(1:2));
        end

        if ~s.session.simulate
            WaitSecs(0.2);
        end

        Screen('TextSize', w, oldTextSize);

        res.respEval(triali) = res.resp(triali) == centralDiri;
        res.cogDisplayTime(triali) = cogDisplayTime;
        res.cogRespTime(triali) = keyDownTime;
        res.rt(triali) = keyDownTime - cogDisplayTime;
    
    end
end