function data = runTests(varargin)

  InitializePsychSound;

  fprintf('*****Loading Settings*****\n')  
  %config_io % resinstall LPT driver, done by getSettings
  s.screen.res=[10 10];
  s = getSettings(s, '', []); 
  
  if isempty(varargin)
      testxdat();
      data=testcom(s);
      testbutton(s);
      testsound(s,1);
      testcomdata(data);

      
  elseif any(cellfun(@(x) strcmp(x,'sound'), varargin ))
      testsound(s,5);
  elseif any(cellfun(@(x) strcmp(x,'com'), varargin ))
      data=testcom(s),
      testcomdata(data);
  end

end

function testcomdata(data)
      %% errors
      if isempty(data) || ~any(data==128)
        error('!!!!!!!SERIAL FAILED!!!!!!!');
      end
end
function testxdat()
  fprintf('****\n\nTESTING XDATS\n');
  fprintf('sending random triggers, check eye tracking computer\n');


  %% send fixed number of xdats
  for i=1:3
      xdat=randi(255);
      fprintf('\tsending %d\n',xdat);
      sendXdat(xdat);
      WaitSecs(1);
  end
  fprintf('****\n\nFINISHED TESTING XDATS\n');
end

function data=testcom(s)
  %% open port and try to read from it
  fprintf('\n\n*****\n');
  fprintf('TESTING SERIAL\n')
 
  dur=1;
  fprintf('Collecting %d secs of data\n',dur)
  WaitSecs(dur);
  try
      %IOPort('Purge',s.serial.handle);
      %%sendXdat(trigger);
      %WaitSecs(1.0); 
      %[data, ~, ~] = IOPort('Read',s.serial.handle);
      IOPort('CloseAll');
      if IsWin
           [h, openErr] = IOPort('OpenSerialPort', 'COM1', 'BaudRate=57600');
      else
           [h, openErr] = IOPort('OpenSerialPort', '/dev/ttyS0', 'BaudRate=57600');
      end
      IOPort('Purge',h);
      WaitSecs(dur);
      [data, when, err] = IOPort('Read',h);
  catch e
      disp(e);
      data=repmat(97,1,10);
  end

      
  %fprintf(1, '%d %d\t%d %d\t%d %d\t%d %d\t%d %d\n', data)
  fprintf('#N.B start with 128, not all 97\n');
  fprintf('first 10 bits: ');
  fprintf('%d ',data(1:min(numel(data), 10)));
  fprintf('\n');
  %[mean(x(1)) mean(y(1))]
  
  
  fprintf('\nFINISHED TEST\nwaiting 1second\n');
  WaitSecs(1);
end

function testbutton(s)
 %% test button box
  fprintf('******\nBUTTON TEST\n\nPush button box 2 or 3: ')

  
  [~,keys,~] = KbWait;
  while ~any(keys(s.keys.finger))
      keys=KbWait();
  end
  fprintf('\n******\n\nButton ACCEPTED\n\n')
end

function testsound(s,n)
 %% play sound
  WaitSecs(1.0);
  fprintf('******\n\nPLAYING SOUND\n\n')
  %InitializePsychSound;

  h = PsychPortAudio('Open', [], [], 1, s.sounds.reward{1}.fs, 2);
  PsychPortAudio('UseSchedule', h, 0);
  %[s,f] = wavread( fullfile(pwd, 'sounds', 'ding-5.wav'));
  %sb=PsychPortAudio('CreateBuffer',s) -- use s.sounds.... instead
  [~, ~, ~] = PsychPortAudio('FillBuffer', h, s.sounds.reward{1}.aud);
  for nsound = 1:n
      PsychPortAudio('Start', h, [], 0, 1);
      % Wait for end of playback, then stop:
      PsychPortAudio('Stop', h, 1);
  end
  % Delete all dynamic audio buffers:
  PsychPortAudio('DeleteBuffer');
  PsychPortAudio('Close');
  fprintf('\n\nDONE PLAYING SOUND\n\n*****\n')
  
end