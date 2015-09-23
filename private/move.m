function timestamp = move(w, s, e)

map = e.map;

colSize = round(s.map.pixSize/s.map.gridSize);

drawMap(w,s)


% show reward
if e.reward == 0
    % you lose, show null
    img = s.images.null;
    snd = s.sounds.null;
else
    img = s.images.reward{e.rewType};
    snd = s.sounds.reward{e.rewType};
end
        
x1 = round( s.screen.res(1)/2 - s.map.pixSize/2);
x2 = x1 + s.map.pixSize;

y1 = round( s.screen.res(2)/2 - s.map.pixSize/2);
y2 = y1 + s.map.pixSize;
    
gridx = map.currentLocation.x;
gridy = map.currentLocation.y;
[imgh,imgw,dim] = size(img.image);
 
xPix = round(x1 + colSize*(gridx-1) + .5*colSize - imgw/2);
yPix = round(y1 + colSize*(gridy-1) + .5*colSize - imgh/2);
imgSize = round(.9*colSize);


Screen('DrawTexture', w, img.tex, [], [xPix yPix xPix+imgw-1 yPix+imgh-1]);
    


% show score
% oldTextSize=Screen('TextSize', w, 64);
% if e.reward
%     DrawFormattedText(w, ['+ ' num2str(s.reward.points(e.rewType))], 'center', .8*s.screen.res(2), ...
%         s.rewards.colors.correct);
% else
%     DrawFormattedText(w, ['+0'], 'center', .8*s.screen.res(2), ...
%         s.rewards.colors.incorrect);
% end
% Screen('TextSize', w, oldTextSize);


[timestamp] = Screen('Flip', w);
% play sounds
if s.sounds.useSounds % & ~isempty(snd)
%    pahandle = PsychPortAudio('Open', [], [], 1, snd.fs, 2);
%    PsychPortAudio('UseSchedule', pahandle, 0);
    [underflow, nextSampleStartIndex, nextSampleETASecs] = PsychPortAudio('FillBuffer', s.pahandle, snd.aud);
    PsychPortAudio('Start', s.pahandle, [], 0, 1);

    % Wait for end of playback, then stop:
    PsychPortAudio('Stop', s.pahandle, 1);

    % Delete all dynamic audio buffers:
    PsychPortAudio('DeleteBuffer');

    % Close audio device, shutdown driver:
%    PsychPortAudio('Close');
end

