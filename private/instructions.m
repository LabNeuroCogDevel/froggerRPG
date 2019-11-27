function instructions(w, s)

    pathname = fullfile(pwd, 'instructions');
    files = dir(fullfile(pathname, '*.jpg'));
    
    slideNum = 1;
    tex = [];
    for i = 1:length(files)
        im = imread(fullfile(pathname, files(i).name));
        im = imresize(im, s.screen.res([2 1]));
        tex(i) = Screen('MakeTexture', w, im);
    end

    keys=s.keys;
    instruct = {...
    [ @showImg ], ...
    [ @showImg ], ...
    [ @showImg ], ...
    [ @showImg ], ...
    [ @doMoveDemo ], ...
    [ @showImg ], ...
    [ @showImg ], ...
    [ @showImg ], ...
    [ @showImg ], ...
    [ @showImg ], ...
    [ @showImg ], ...
    [ @showImg ], ...
    [ @showImg ] ...
    };
    
    
    

   
    KbCheck;
    for i = 1:length(instruct)
      % add newlines for windows
      if ispc
       % instruct{i}=strrep('\n','\n\n');
      end
      
      if ischar(instruct{i})
          DrawFormattedText(w,instruct{i},'center','center',[ 1 1 1 ]*255);
          Screen('Flip',w);
          WaitSecs(.5);
          [secs, keyCode, deltaSecs] =KbWait;
      else
          instruct{i}();
      end
      %escclose(keyCode);
    end

    
    function showImg()
        
        
        Screen('DrawTexture', w, tex(slideNum), []);
        [timestamp] = Screen('Flip', w);

        WaitSecs(0.5);
        KbWait;
        slideNum = slideNum+1;
        
    end

    function doPromptDemo()
        m.visitOutcomes = NaN*ones(s.map.gridSize, s.map.gridSize, 1000);
        m.currentLocation.x = 2;
        m.currentLocation.y = 3;
        
        moveOpts(1).value = 1;
        moveOpts(1).x = 1;
        moveOpts(1).y = 3;
        
        moveOpts(2).value = 2;
        moveOpts(2).x = 2;
        moveOpts(2).y = 2;
        
        e = [];
        e.map=m;
        updateMap(w, s, e, [], moveOpts);
        WaitSecs(0.5);
        KbWait;
%        WaitSecs(3.0);
    end


    function doMoveDemo()
        m.visitOutcomes = NaN*ones(s.map.gridSize, s.map.gridSize, 1000);
        m.currentLocation.x = 2;
        m.currentLocation.y = 3;
        moveOpts(1).value = 1;
        moveOpts(1).x = 1;
        moveOpts(1).y = 3;
        
        moveOpts(2).value = 2;
        moveOpts(2).x = 2;
        moveOpts(2).y = 2;
        
        e = [];
        e.map=m;
        updateMap(w, s, e, [], moveOpts);
        WaitSecs(1.0);
        
        e = [];
        e.map=m;
        updateMap(w, s, e, [2 2]);
        WaitSecs(1.0);

        m.currentLocation.x = 2;
        m.currentLocation.y = 2;  
        
        e = [];
        e.map=m;
        e.reward = 1;
        e.rewType = 2;
        move(w, s, e);
%        WaitSecs(2.0);
        WaitSecs(0.5);
        KbWait;

    end


    function doFixationDemo()
        e = [];
        e.cogRewType = 2;
        
        event_Fix(w, s, e, 1);
%        WaitSecs(2.0);
        WaitSecs(0.5);
        KbWait;

    end

    function doFlankerDemo()
        %flanker(w, s, [], forceCongruent, forceCentralDir)
        flanker(w, s, [], 1, 0);
        oldTextSize=Screen('TextSize', w, 32);
        DrawFormattedText(w,'Correct:\n\n<\n\n','center','center',[ 0 0 0 ]);
        Screen('Flip',w);
        Screen('TextSize', w, oldTextSize);
        WaitSecs(2);
        
        flanker(w, s, [], 0, 0);
        oldTextSize=Screen('TextSize', w, 32);
        DrawFormattedText(w,'Correct:\n\n<\n\n','center','center',[ 0 0 0 ]);
        Screen('Flip',w);
        Screen('TextSize', w, oldTextSize);
        WaitSecs(2);
       
    end

end
