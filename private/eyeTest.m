%% record

IOPort('CloseAll');

if iswin
    [h, openErr] = IOPort('OpenSerialPort', 'COM2', 'BaudRate=57600')
else
    [h, openErr] = IOPort('OpenSerialPort', '/dev/ttyS0', 'BaudRate=57600')
end

WaitSecs(0.5);

trigger = 0;
log = [];
while 1
    
    keyIsDown = 0; validKey = 0;
    while ~keyIsDown | ~validKey
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        keyName = KbName(keyCode);
        if keyIsDown
            %keyName
        end
        validKey = strcmp(lower(keyName), 'return');
    end
    
    trigger = trigger + 1;
    IOPort('Purge',h);
    %sendXdat(trigger);
    WaitSecs(1.0); 
    [data, when, err] = IOPort('Read',h)
    %fprintf(1, '%d %d\t%d %d\t%d %d\t%d %d\t%d %d\n', data)
    [x,y] = decodeEyeData(data(1:floor(length(data)/10)*10), [5 6], [7 9], 10);
    [x' y']
%    [trigger mean(x) mean(y)]
    [trigger mean(x(1)) mean(y(1))]
    log = [log; trigger x(1) y(1)];
    
    WaitSecs(0.5);
end

return

%% read xdat
xdat_file = fullfile('/home/lncd/B/bea_res/Personal/Will/eyetracking/eye2.txt');
xdat = load(xdat_file);

triggers = xdat(:,1);
pupil_diam = xdat(:,2);
x = xdat(:,3);
y = xdat(:,4);

uniqueTriggers = unique(triggers);
for ti = 1:length(uniqueTriggers)
    
    ind = find(triggers == uniqueTriggers(ti), 1, 'first');
    for inc = 0:3
        try
            fprintf(1, '%d\t%.1f\t%.1f\n', triggers(ind+inc), x(ind+inc), y(ind+inc));
        catch
        end
    end
end
