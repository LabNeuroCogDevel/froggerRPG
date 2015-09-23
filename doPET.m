%function doPET(subj)

addpath('/home/lncd/linux_parallel_port_ptb_ratrix/')

subj = input('Subject ID: ', 's');
startRun = input('Start on run (1): ', 's');
if isempty(startRun)
    startRun = 1;
else
    startRun = str2double(startRun);
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
