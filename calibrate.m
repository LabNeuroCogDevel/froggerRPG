%% calibrate -- display numbered dots for calibrating eye tracking
%  arrow keys, space, q, and esc control presentation
%  uses private/showCal to do displaying
%  ---
%  will take a window w as an argument, otherwise will open a new window
%  with setupscreen

function calibrate(varargin)

  KbName('UnifyKeyNames');

  if ~ismac && IsWin
    config_io
  end
  
  if ~isempty(varargin) && length(varargin) > 1
     w=varargin{1};
     res=varargin{2};
  else
     % [w, res] = Screen('OpenWindow', 0, [120 120 120],[0 0 800 600]);
     [w,res] = setupScreen([120 120 120], []);
  end

  
  % do we want to send xdats (do we have a serial connection
  %fprintf('initializing, should be sending 0\n');
  sendincxdat(0);
  index=0;

  key = showCal(w,res,0);

  while ~ any(key( KbName({'Escape','q'})  ))

   if key( KbName('=+')  )
       sendincxdat();
       
   elseif key( KbName('LeftArrow')  )
     index=index-1;
   elseif any(key( KbName({'RightArrow','Space'})  ))
       if key(KbName({'Space'})) 
           sendincxdat(0);
       end
     index=index+1;
   elseif key( KbName('UpArrow')  )
     index=index-3;
   elseif key( KbName('DownArrow')  )
     index=index+3;
   else
     fprintf('bad key\n');
   end

   index=mod(index,9);
   if index == 0, index = 9; end

   key = showCal(w,res,index);

  end
  
  % close screen if we didn't have one when we started
  if isempty(varargin); Screen('CloseAll'); end
end

function sendincxdat(varargin)
  persistent INCXDAT
  if isempty(INCXDAT), INCXDAT=0; end
  if nargin>=1, INCXDAT=varargin{1};  end 
  
  % fprintf('sending %d %d\n',t,INCXDAT);
  sendXdat(INCXDAT);
  fprintf(1, 'setting %d\n',INCXDAT);
  INCXDAT=mod(INCXDAT,254)+1;
end