
if isempty(s) || ~isfield(s, 'screen')
    [w,res]=setupScreen([120 120 120], []);
    s.screen.res = res(3:4);
    sca
    
end
s = getSettings(s, '', 0); 

for runNum = 1:6
    fprintf(1, '\n\nChecking run #%d\n', runNum);
    e = genEventList(s, runNum);
    showEventTimes(e)
    pause
end
