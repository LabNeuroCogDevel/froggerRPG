
cd('C:\Users\Luna\Desktop\RPG_task_pairedprob-master')

subj = input('Subject ID: ', 's');
subj = [subj '_practice'];
startRun = 1;


% behave: so no eyetracking, not sensorimotor control
eyeTrack = 0;
smmode = [];

w = []; 

s = []; 
map = []; 
e = [];
%[w, s, map, e] = RPG(subj,w, map,s,startRun, smmode, eyeTrack); 

setupPractice(subj);


