
function timestamp = bonus_round(w, s, e, showReward, textString, textColor)

    if nargin<4 || isempty(showReward)
        showReward = 0;
    end
    
    if nargin<5 || isempty(textString)
        textString = 'Look-Away Game!';
    end
    
    if nargin<6 || isempty(textColor)
        textColor = s.anti.colors.text;
    end
        
    oldTextSize=Screen('TextSize', w, 48);
    DrawFormattedText(w, textString , 'center', 'center', ...
                    textColor);
    if showReward
        img = s.images.cogreward{e.cogRewType};
        [imgh,imgw,dim] = size(img.image);

        x1 = s.screen.res(1)/2 - imgw/2;
        
        if e.cogRewType==1
            y1 = s.screen.res(2)/2 + .75*imgh;
        else
            y1 = s.screen.res(2)/2 + 1.3*imgh;
        end

            
        Screen('DrawTexture', w, img.tex, [], [x1 y1 x1+imgw-1 y1+imgh-1]);        
    end
    
    Screen('TextSize', w, oldTextSize);
    [v,timestamp] = Screen('Flip',w);
    if ~s.session.simulate
    %    WaitSecs(0.5);
    end
  
    
end
