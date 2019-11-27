%function doPET(subj)

clear

if ~ismac && iswin
    config_io
else
    addpath('/home/lncd/linux_parallel_port_ptb_ratrix/')
end

subj = input('Subject ID: ', 's');
startRun = input('Start on run (1): ', 's');
if isempty(startRun)
    startRun = 1;
else
    startRun = str2double(startRun);
end

if startRun > 1
    for i = 1:startRun-1
        matfile = sprintf('results/results_%s_%d.mat', subj, i);
        if ~exist(matfile, 'file')
            error('Could not find completed results file %s', matfile);
        else
            fprintf(1, 'Loading %s...\n', matfile);
            load(matfile);
        end
    end
else
    matfile = sprintf('results/results_%s_%d.mat', subj, 1);
    if exist(matfile, 'file') && ~strcmp(subj, 'test')
        fprintf(1, 'Warning: already have results file %s for subj %s\n', matfile, subj);
        cont = input('Continue anyway? (Y/n): ', 's');
        if strcmp(cont, 'n')
            return;
        end
    end
        
end

eyeTrack = input('Use eye tracker? (1 yes, 0 no): ');
if isempty(eyeTrack)
    eyeTrack = 1;
end
if ~any(eyeTrack == [0 1])
    eyeTrack = 0;
end

smmode=[];
% we are always doing main task now
%task = input('Main task (1) or sensorimotor control (2): ');
%if task == 2
%    smmode = 'smcontrol';
%else
%    smmode = [];
%end

w = []; 
if startRun == 1
    s = []; 
    map = []; 
    e = [];
end

for i = startRun:6
    [w, s, map, e] = RPG(subj,w, map,s,i, smmode, eyeTrack); 
end


% line 553:
%                      if [e(ei).cogRes.respEval] | ~eyetrack
