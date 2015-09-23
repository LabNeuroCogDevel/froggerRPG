% usage: WaitForKey({'Enter','q','Esc'});
function WaitForKey(wants)
  keyCode=zeros(1,256);
  wantidxs=KbName(wants);
  while ~ any(keyCode(wantidxs))
      [keyIsDown, secs, keyCode] = KbCheck;
  end
end