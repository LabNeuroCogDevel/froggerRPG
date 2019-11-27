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

%WF 2016-03-02 -- never do smcontrol, so dont ask
% task = input('Main task (1) or sensorimotor control (2): ');
% if task == 2
%     smmode = 'smcontrol';
% else
%     smmode = [];
% end

smmode = [];

w = []; 
if startRun == 1
    s = []; 
    map = []; 
    e = [];
end

for i = startRun:1
    [w, s, map, e] = RPG(subj,w, map,s,i, smmode, eyeTrack); 
end

% WF 2016-03-04 -- close everything when dones
Screen('CloseAll');
% line 553:
%                      if [e(ei).cogRes.respEval] | ~eyetrack
