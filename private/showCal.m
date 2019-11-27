function key = showCal(w, res,varargin)

    if ~isempty(varargin)
       rednum=varargin{1};
    else
       rednum=0;
    end

    keyIsDown = 1;
    while keyIsDown
        keyIsDown = KbCheck;
    end
    
    if length(res)==2
        rx = res(1);
        ry = res(2);
    else
        rx = res(3);
        ry = res(4);
    end
    
    gridSize = [3 3];
    offset = 75;
    innerRadius = 5;
    outerRadius = 20;
    
    
    effx = rx - 2*offset;
    effy = ry - 2*offset;
    
    spacingx = round(effx/(gridSize(1)-1));
    spacingy = round(effy/(gridSize(2)-1));
    
    for xi = 1:gridSize(1)
        for yi = 1:gridSize(2)

            num = 3*(yi-1) + xi;

            
            cx = offset + spacingx*(xi-1);
            cy = offset + spacingy*(yi-1);
            
            if num == rednum
              ovalcolor = [240 30 30 ];
            else
              ovalcolor = [.46 .54 .60]*255;
            end

            rect = [cx-outerRadius cy-outerRadius cx+outerRadius cy+outerRadius];
            Screen('FillOval', w, ovalcolor, rect);
            
            rect = [cx-innerRadius cy-innerRadius cx+innerRadius cy+innerRadius];
            Screen('FillOval', w, [1 1 1]*255, rect);

            % number
            DrawFormattedText(w,num2str(num),cx+outerRadius,cy+outerRadius,[0 0 0])
            
        end
    end
    
    Screen('Flip', w);
    
    % 20180103 WF - new button box scanner trigger is too fast for kbwait
    % [secs,key,deltaSecs]=KbWait;
    % use queue
    KbQueueCreate(); KbQueueStart();
    pressed = 0;
    while ~ pressed
        [pressed, firstPress, ~, ~,~] = KbQueueCheck();
        key = firstPress;
    end
    % this takes about 0.090 seconds
    KbQueueStop(); KbQueueRelease();
end
