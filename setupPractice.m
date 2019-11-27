    
%WF 20160421 -- practice computer died. lost previous code. need to
%practice in the control room.


function [w,e,m] = setupPractice(subj)
    config_io;
    InitializePsychSound;
    
    [w,res]=setupScreen([120 120 120], []);
    s.screen.res = res(3:4);    
    
    
    s = getSettings(s, 'upmc_56ce704785', []);
    s.events.totalScore = 0;

    % this has no effect :(
    % will be overwritten by RPG
    s.host.isMR=0; s.host.isBehave=1;s.host.name='ControlRoomPractice';s.host.type='Behave';
    s.keys.finger = KbName({'1','2','1!','2@', 'ESCAPE'}); 
    %s.session.simulate = 1;

    
    m=[];
    startRun=1;
    eyeTrack=0;
    
    [w, s, map, e] = RPG(subj,w, m,s,startRun, [], eyeTrack); 
    maptest(w, s, 10, map, 'random');
    sca
    
    
end