
function timestamp = event_Fix(w, s, e, showReward)
    if nargin<4 || isempty(showReward)
        showReward = 0;
    end
        
    drawCross(w,s.fix.color);

    if showReward
        e.cogRewType
        img = s.images.cogreward{e.cogRewType};
        [imgh,imgw,dim] = size(img.image);

        x1 = s.screen.res(1)/2 - imgw/2;
        y1 = s.screen.res(2)/2 - 1.2*imgh;
        Screen('DrawTexture', w, img.tex, [], [x1 y1 x1+imgw-1 y1+imgh-1]);        
    end
    
    [v,timestamp] = Screen('Flip',w);
    if ~s.session.simulate
    %    WaitSecs(0.5);
    end
  
end
