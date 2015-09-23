%% calibrate -- display numbered dots for calibrating eye tracking
%  arrow keys, space, q, and esc control presentation
%  uses privae/showCal to do displaying

function calibrate

  KbName('UnifyKeyNames');

  % [w, res] = Screen('OpenWindow', 0, [120 120 120],[0 0 800 600]);
  [w,res] = setupScreen([120 120 120], []);
  key = showCal(w,res,5);
  index=0;

  while ~ any(key( KbName({'Escape','q'})  ))

   if key( KbName('LeftArrow')  )
     index=index-1;
   elseif any(key( KbName({'RightArrow','Space'})  ))
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
  Screen('CloseAll');
end