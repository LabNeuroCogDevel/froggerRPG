function drawMap(w, s)

colSize = round(s.map.pixSize/s.map.gridSize);

x1 = round( s.screen.res(1)/2 - s.map.pixSize/2);
x2 = x1 + s.map.pixSize;

y1 = round( s.screen.res(2)/2 - s.map.pixSize/2);
y2 = y1 + s.map.pixSize;


% draw outer grid
Screen('FillRect', w, s.map.colors.line, [x1-1 y1-1 x2+1 y2+1]);
Screen('FillRect', w, s.map.colors.bg, [x1 y1 x2 y2]);

% draw background
Screen('DrawTexture', w, s.images.bg.tex, []);%x1 y1 x2 y2]);

% draw inner grid lines
for i = 1:s.map.gridSize-1
    Screen('FillRect', w, s.map.colors.line, [x1 y1+i*colSize x2 y1+i*colSize+1]);
    Screen('FillRect', w, s.map.colors.line, [x1+i*colSize y1 x1+i*colSize+1 y2]);
end
