

function map_only %(subj,eyetrack)

    subj = input('Subj ID: ','s');
    
    files = dir(sprintf('results/results_%s*.mat', subj));
    fprintf(1, 'Found %d files\n', length(files));
    load(sprintf('results/%s', files(end).name));
    fprintf(1, 'Loading %s\n', files(end).name);
    fprintf(1, 'Press enter to begin\n');
    pause
    %s = getSettings(s, '', ''); 

    WaitSecs(1.0);
    
    [w,res]=setupScreen([120 120 120], []);s.screen.res = res(3:4);
    s.images.me.tex = Screen('MakeTexture', w, s.images.me.image);
    s.images.reward{1}.tex = Screen('MakeTexture', w, s.images.reward{1}.image);
    s.images.reward{2}.tex = Screen('MakeTexture', w, s.images.reward{2}.image);
    s.images.cogreward{1}.tex = Screen('MakeTexture', w, s.images.cogreward{1}.image);
    s.images.cogreward{2}.tex = Screen('MakeTexture', w, s.images.cogreward{2}.image);
    s.images.null.tex = Screen('MakeTexture', w, s.images.null.image);
    s.images.bg.tex = Screen('MakeTexture', w, s.images.bg.image);
    s.images.progress_bg.tex = Screen('MakeTexture', w, s.images.progress_bg.image);
    
    
    sendXdat(0);
    
    DrawFormattedText(w, ...
        ['Good job!  Now we''ll see how well you learned the map.\n\n' ...
         'For each of the squares you''ll be shown, indicate\n\n' ...
         'which one you gave you more rewards.\n\n\n\n' ...
         '(Press any key to start)'], ...
        'center','center',[ 1 1 1 ]*255);
    Screen('Flip', w);
    KbWait;
    finalMaptestResults = maptest(w, s, 50, map, 'random');

    save(sprintf('results/results_%s_%d_maponly.mat', subj, runNum), 's','map','e','finalMaptestResults','starttime','runNum');

    sca
    
end