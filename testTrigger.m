function testTrigger(method)
    KbName('UnifyKeyNames')
    WaitSecs(.5);
    
    % KbCheck, KbWait , KbQueue
    % default KbQueue
    if nargin < 1
        method='KbQueue';
    end
    if strcmp(method, 'KbCheck')
        methodfn=@withcheck;
    elseif strcmp(method, 'KbWait')
        methodfn=@withwait;
    else
        method='KbQueue';
        methodfn=@withqueue;
    end
    
    % endless loop
    %listenChar(2);
    fprintf('listening for keys with %s -- Ctrl+c to quit\n',method);
    while 1 % ~scannerTrigger
        keyname = methodfn();
    end
    %listenChar(0);
end

function keyname = withcheck()
    scannerTrigger=0;
    keyname='';
    while ~scannerTrigger
        [keyIsDown, keyPressTime, keyCode] = KbCheck;
        if any(keyCode)
            keyname=KbName(keyCode);
            fprintf('got:\n')
            disp(keyname)
            %find(keyCode);
        end
        if strcmp( keyname, '=+' ) | strcmp( keyname, '=' )
           fprintf('triggered!');
           scannerTrigger = 1;
        end
        WaitSecs(.1);% so we dont spam the screen
    end 
    keyname = KbName(keyCode);
end

function keyname = withwait()
   keyname = '';
   while ~ any(ismember({'=','=+'},keyname) )
       [secs, keyCode, deltaSecs] = KbWait;
       keyname = KbName(keyCode);
       fprintf('%d recived ',secs); disp(keyname)
       %WaitSecs(.1); % so we dont spam the screen
   end
   fprintf('triggered!\n')
end

function keyname = withqueue()
    scannerTrigger=0;
    while ~scannerTrigger
        % 20180103WF button box changed
        % previous KbCheck code does not work
        % newer KbWait also fails
        % need KbQueue
        KbQueueCreate(); KbQueueStart()
        while ~ scannerTrigger
               [pressed, firstPress, ~, ~,~] = KbQueueCheck();
               keyname = KbName(firstPress);
               scannerTrigger = pressed && ...
                              any(ismember({'=','=+'}, keyname));
               ttime=GetSecs();
        end
        fprintf('\ntriggered @ %f ',ttime);
        % release so we can get subject button pushes with KbCheck
        % not sure if this takes a long time
        KbQueueStop(); KbQueueRelease();
        ftime=GetSecs();
        fprintf('cleared at %f, diff: %f\n',ftime,ftime-ttime)
    end
end