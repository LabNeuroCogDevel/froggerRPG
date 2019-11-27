function r = maptest(w, s, n, map, pickMethod)

e = [];
map.currentLocation.x = [];
map.currentLocation.y = [];

e.map = map;

nVisits = sum(~isnan(map.visitOutcomes),3);
nRew = sum(map.visitOutcomes>=1,3);
nHigh = sum(map.visitOutcomes>=2,3);

pRew = nRew ./ nVisits;
pHigh = nHigh ./ nVisits;

expVal = 10*pRew + (50-10)*pHigh;

r = [];

% build table of # visits
table = [];
for x = 1:size(map.visitOutcomes,1)
    for y = 1:size(map.visitOutcomes,2)
        table(end+1,:) = [x y nVisits(x,y) nRew(x,y) nHigh(x,y) pRew(x,y) pHigh(x,y) expVal(x,y)];
    end
end
table = sortrows(table, -3);

% build hybrid table
hybrid = [];
for x1 = 1:size(map.visitOutcomes,1)
    for y1 = 1:size(map.visitOutcomes,1)
        for x2 = 1:size(map.visitOutcomes,1)
            for y2 = 1:size(map.visitOutcomes,1)
                n1 = nVisits(x1,y1);
                n2 = nVisits(x2,y2);
                p1 = pRew(x1,y1);
                p2 = pRew(x2,y2);
                valid = (x1 <= x2) & (y1 <= y2) & ((x1 ~= x2) | (y1 ~= y2)) & (n1 > 0) & (n2 > 0);
                hybrid(end+1,:) = [x1 y1 x2 y2 n1 n2 1-abs(n1-n2)/(n1+n2) p1 p2 abs(p1-p2) valid];
            end
        end
    end
end
hybrid_norm = hybrid ./ repmat(max(hybrid),[size(hybrid,1) 1]);
score = (randn(size(hybrid,1),1) + sum(hybrid_norm(:,[5 6 7 10]),2)).*hybrid_norm(:,11);
hybrid = sortrows([hybrid score], -12);
%hybrid(1:nnz(score),:)

for triali = 1:n
    moveOpts = [];
    moveOpts(1).value = 1;
    moveOpts(2).value = 2;

    % pick test squares
    switch pickMethod
        
        case 'matchedVisits'
            i1 = 2*triali-1;
            i2 = i1+1;

            moveOpts(1).x = table(i1,1);
            moveOpts(1).y = table(i1,2);
            

            moveOpts(2).x = table(i2,1);
            moveOpts(2).y = table(i2,2);
            
        case 'random'
            
            same = 1;
            while same
                moveOpts(1).x = randi(s.map.gridSize, 1);
                moveOpts(1).y = randi(s.map.gridSize, 1);
                moveOpts(2).x = randi(s.map.gridSize, 1);
                moveOpts(2).y = randi(s.map.gridSize, 1);
                
                same = ( (moveOpts(1).x==moveOpts(2).x) && (moveOpts(1).y==moveOpts(2).y) );
            end
            
        case 'hybrid'
            
            thisInd = mod(triali-1, nnz(score))+1;
            moveOpts(1).x = hybrid(thisInd,1);
            moveOpts(1).y = hybrid(thisInd,2);
            moveOpts(2).x = hybrid(thisInd,3);
            moveOpts(2).y = hybrid(thisInd,4);
            
            
    end
       
    % save some info about squares being tested
    for i = 1:2
        moveOpts(i).nVisits = nVisits(moveOpts(i).x, moveOpts(i).y);
        moveOpts(i).nRew = nRew(moveOpts(i).x, moveOpts(i).y);
        moveOpts(i).nHigh = nHigh(moveOpts(i).x, moveOpts(i).y);
        moveOpts(i).pRew = pRew(moveOpts(i).x, moveOpts(i).y);
        moveOpts(i).pHigh = pHigh(moveOpts(i).x, moveOpts(i).y);
        moveOpts(i).expVal = expVal(moveOpts(i).x, moveOpts(i).y);
    end
        
    r(triali).moveOpts = moveOpts;
    r(triali).trialStartTime = updateMap(w, s, e, [], moveOpts);

    sendXdat(triali);

    % wait for move choice
    keyIsDown = 0;
    validResponse = 0;
    validKeys = s.keys.finger;
    if length(s.keys.finger >= 5) % we have an exit button
        validKeys(end+1) = s.keys.finger(5);
    end

    %validResponse = ~isempty(find(keyCode)) && any(find(keyCode,1,'first')==validKeys);
    %
    testOnset = GetSecs;
    while (~keyIsDown | ~validResponse) & GetSecs<(testOnset+3)
        [keyIsDown, keyDownTime, keyCode] = KbCheck;
        validResponse = ~isempty(find(keyCode)) && any(find(keyCode,1,'first')==validKeys);
    end

    if find(keyCode,1,'first')==s.keys.finger(5)
        break;
    end

    if validResponse
        r(triali).keyPressName = s.keys.string{find(find(keyCode,1,'first')==s.keys.finger)};
        r(triali).resp = str2double(r(triali).keyPressName);
        r(triali).responseTime = keyDownTime;
        r(triali).rt = keyDownTime - r(triali).trialStartTime;
    else
        r(triali).keyPressName = [];
        r(triali).resp = [];
        r(triali).responseTime = [];
        r(triali).rt = [];
    end
    
    updateMap(w, s, e);
    WaitSecs(1.0);


end
