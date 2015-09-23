function showCal(w, res)

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
    
    for xi = 1:gridSize
        for yi = 1:gridSize
            
            cx = offset + spacingx*(xi-1);
            cy = offset + spacingy*(yi-1);
            

            rect = [cx-outerRadius cy-outerRadius cx+outerRadius cy+outerRadius];
            Screen('FillOval', w, [.46 .54 .60]*255, rect);
            
            rect = [cx-innerRadius cy-innerRadius cx+innerRadius cy+innerRadius];
            Screen('FillOval', w, [1 1 1]*255, rect);
            
        end
    end
    
    Screen('Flip', w);
    KbWait;
end
            
            