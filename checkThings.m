function [w,s]= checkThings()
 % screen and load images
 [w,r] = Screen('OpenWindow',0,120.*[1 1 1],[0 0 800 600]);
 s.screen.res =r(3:4);
 s.host.name = 'test';
 s=getSettings(s,'',[]);
 s=maketex(w,s);
 
 e(1).cogPoints=10; e(1).mapPoints=10;
 showProgress(w,s,e,[],1)

end
