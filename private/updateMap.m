function timestamp = updateMap(w, s, e, highlight, numbers, valStrs)

%    % map settings
%     s.map.gridSize = 4;
%     s.map.pixSize = 500;
%     s.map.colors.line = [255 255 255];
%     s.map.colors.bg = [255 255 255]*.4;
%     
%     % images
%     [s.images.me.image s.images.me.map s.images.me.alpha] = imread(fullfile(pwd, 'img', 'ash-ketchum.gif'));
%     [s.images.reward{1}.image s.images.reward{1}.map s.images.reward{1}.alpha] = imread(fullfile(pwd, 'img', 'money-bag-single.png'));
%     [s.images.reward{2}.image s.images.reward{2}.map s.images.reward{2}.alpha] = imread(fullfile(pwd, 'img', 'money-bag-three.png'));

% [left, top, right, bottom] of

if nargin<4 || isempty(highlight) || length(highlight)~=2
    highlight = [];
end

if nargin<5 || isempty(numbers)
    numbers = [];
    % struct with fields value, x, y
end

if nargin<6 || isempty(valStrs)
    if isempty(numbers)
        valStrs = {'', ''};
    else
        valStrs = {num2str(numbers(1).value), num2str(numbers(2).value)};
    end
end


map = e.map;

colSize = round(s.map.pixSize/s.map.gridSize);

drawMap(w,s)
    
x1 = round( s.screen.res(1)/2 - s.map.pixSize/2);
x2 = x1 + s.map.pixSize;

y1 = round( s.screen.res(2)/2 - s.map.pixSize/2);
y2 = y1 + s.map.pixSize;

% draw me
if ~isempty(map.currentLocation.x) & isempty(highlight)
    gridx = map.currentLocation.x;
    gridy = map.currentLocation.y;
    [imgh,imgw,dim] = size(s.images.me.image);

    xPix = round(x1 + colSize*(gridx-1) + .5*colSize - imgw/2);
    yPix = round(y1 + colSize*(gridy-1) + .5*colSize - imgh/2);
    imgSize = round(.9*colSize);
    Screen('DrawTexture', w, s.images.me.tex, [], [xPix yPix xPix+imgw-1 yPix+imgh-1]);
end

% draw highlight
if ~isempty(highlight)
    hx = highlight(1);
    hy = highlight(2);

%    hx1 = x1 + colSize*(hx-1);
%    hy1 = y1 + colSize*(hy-1);
%    Screen('FillRect', w, s.map.colors.highlight, [hx1 hy1 hx1+colSize hy1+colSize]);
    [imgh,imgw,dim] = size(s.images.me.image);

    xPix = round(x1 + colSize*(hx-1) + .5*colSize - imgw/2);
    yPix = round(y1 + colSize*(hy-1) + .5*colSize - imgh/2);
    imgSize = round(.9*colSize);
    Screen('DrawTexture', w, s.images.me.tex, [], [xPix yPix xPix+imgw-1 yPix+imgh-1]);

end

% draw move choices
if ~isempty(numbers)
    for i = 1:length(numbers)
        hx = numbers(i).x;
        hy = numbers(i).y;
        val = numbers(i).value;
        
        hx1 = x1 + colSize*(hx-1);
        hy1 = y1 + colSize*(hy-1);
        
        oldTextSize=Screen('TextSize', w, 64);
        [nx, ny, textbounds] = DrawFormattedText(w, valStrs{val}, 'center', 'center', ...
            s.map.colors.text, [], [], [], [], [], ...
            [hx1 hy1 hx1+colSize hy1+colSize]);
        Screen('TextSize', w, oldTextSize);
    end
end

% show score
% oldTextSize=Screen('TextSize', w, 64);
% DrawFormattedText(w, ['Score: ' num2str(e.score)], 'center', .9*s.screen.res(2), ...
%     s.map.colors.score);
% Screen('TextSize', w, oldTextSize);

    
[timestamp] = Screen('Flip', w);

