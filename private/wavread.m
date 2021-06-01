function [out, rate] = wavread(wav)
   % replace legacy code like
   % [s.sounds.beep.aud, s.sounds.beep.fs] = wavread(s.sounds.beep.fname);
    aInfo = audioinfo(wav);
    rate = aInfo.SampleRate;
    out = audioread(wav);
end