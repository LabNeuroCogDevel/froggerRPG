function [res, cogOnset] = anti(w, s, e, targetSide, targetEcc)
    
    if nargin < 4
        targetSide = [];
    end
    
    if nargin < 5
        targetEcc = [];
    end

    if isempty(targetSide)
        res.targetSide = sign(randn); % -1 = left, 1 = right
    else
        res.targetSide = targetSide;
    end
    
    if isempty(targetEcc)
        res.targetEcc = rand>0.5; % 0 = near, 1 = far
    else
        res.targetEcc = targetEcc;
    end
    
    %drawCross(w,s.fix.color);
    [v,onset] = Screen('Flip',w);
    if ~s.session.simulate
        WaitSecs(0.5);
    end    
    
    ecc = [];
    screenWidthPix = s.screen.res(1);
    screenMidPix = round(screenWidthPix/2);
    ecc(1) = round(.165*screenWidthPix);
    ecc(2) = 2*ecc(1);
    
    
    targetCenterX = screenMidPix + res.targetSide*ecc(res.targetEcc + 1);
    targetCenterY = round(s.screen.res(2)/2);
    
    targetRect = round([targetCenterX-s.anti.targetDiamPix/2 ...
                        targetCenterY-s.anti.targetDiamPix/2 ...
                        targetCenterX+s.anti.targetDiamPix/2 ...
                        targetCenterY+s.anti.targetDiamPix/2]);

    
%     s.anti.colors.target = [1 1 0]*255;
%     s.anti.colors.correct = s.rewards.colors.correct;
%     s.anti.colors.incorrect = s.rewards.colors.incorrect;
%     s.anti.displayTime = 0.1;
%     s.anti.maxRespTime = 1.5;
%     s.anti.targetDiamPix = 10;

    Screen('FillOval', w, s.anti.colors.target, targetRect);
    cogDisplayTime = Screen('Flip', w);
    cogOnset = cogDisplayTime;

    if s.session.simulate
        cogDisplayTime = cogDisplayTime - 100000;
    end    

    while GetSecs < (cogDisplayTime + s.anti.displayTime)
        WaitSecs(0.005);
    end
    
    Screen('Flip', w);
    
    while GetSecs < (cogDisplayTime + s.anti.maxRespTime)
        WaitSecs(0.005);
    end
    

     res.cogDisplayTime(1) = cogDisplayTime;
    
end