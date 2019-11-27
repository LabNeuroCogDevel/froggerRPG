% usage: WaitForKey({'Enter','q','Esc'});
function keyName = WaitForKey(wants)
  keyName = '';
  keyCode=zeros(1,256);
  wantidxs=KbName(wants);
  while ~ any(keyCode(wantidxs))
      [keyIsDown, secs, keyCode] = KbCheck;
  end
  keyName = KbName(keyCode);
end