function s=maketex(w,s)
    s.images.me.tex           = Screen('MakeTexture', w, s.images.me.image);
    s.images.reward{1}.tex    = Screen('MakeTexture', w, s.images.reward{1}.image);
    s.images.reward{2}.tex    = Screen('MakeTexture', w, s.images.reward{2}.image);
    s.images.cogreward{1}.tex = Screen('MakeTexture', w, s.images.cogreward{1}.image);
    s.images.cogreward{2}.tex = Screen('MakeTexture', w, s.images.cogreward{2}.image);
    s.images.null.tex         = Screen('MakeTexture', w, s.images.null.image);
    s.images.bg.tex           = Screen('MakeTexture', w, s.images.bg.image);
    s.images.progress_bg.tex  = Screen('MakeTexture', w, s.images.progress_bg.image);
end