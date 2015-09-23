% hard coded settings like color screen size, response keys
function s=getSettings(s, host, smmode)
  %persistent s;

  if nargin < 1
      s = [];
  end
  
  if nargin < 2
      host = [];
  end
  
  if nargin < 3
      mode = []; % otherwise, 'smcontrol' for sensorimotor control
  end
  


 %% get host name and set info related to it
 %% we can also specify a host name as a (second) option
 if isempty(host)
    [returned,host] = system('hostname');
    host=strtrim(host);
    host(host=='-')='_';
 end 

 % behave true => fixed .5sec ITI
 % MR          => show getready screen
 % MEG         => send trigger codes and photodiode
 s.host.name = host;
 if strncmp(host,'Admin_PC',8)
  s.host.type='MR';
  s.host.isMR=1;
  s.host.isBehave=0;
  s.host.isMEG=0;
  %s.screen.res=[1024 768];   % MRCTR
  fprintf('running MR\n');
 elseif strncmp(host,'MEGPC',5)
  s.host.type='MEG';
  s.host.isMR=0;
  s.host.isBehave=1;
  s.host.isMEG=1;
  %s.screen.res=[1024 768]; 
 elseif strncmp(host,'upmc_56ce704785',15)
  s.host.type='Behave';
  s.host.isMR=0;
  s.host.isBehave=1;
  s.host.isMEG=0;
  %s.screen.res=[1440 900];
 else
  s.host.type='Unknown';
  s.host.isMR=0;
  s.host.isBehave=1;
  s.host.isMEG=0;
  %s.screen.res=[1024 768];   
 end

 fprintf('screen res: %d %d %s\n',s.screen.res,s.host.name);     
 s.info.MLversion= version();
 s.info.PTBversion = PsychtoolboxVersion();
 fprintf('Versions: %s PTB %s\n',s.info.MLversion,s.info.PTBversion);

 s.session.maxRuns = 6;
 s.session.simulate = 0;
 
 %s.screen.res=[800 600];   % any computer, testing
 %s.screen.res=[1600 1200]; % will's computer
 %s.screen.res=[1280 1024]; %test computer in Loeff
 s.screen.bg=[120 120 120];

 KbName('UnifyKeyNames')

 % use fingers:  index, middle, ring, pinky
 if s.host.isMR
   % Button Glove 
   s.keys.finger = KbName({'2','3','4','5'}); 
 else
%   s.keys.finger = KbName({'1!','2@','3','4', 'ESCAPE'}); 
   s.keys.finger = KbName({'2@','3#','2','3', 'ESCAPE'}); 
 end

 % string corresponding to finger
 % MUST BE numeric
 s.keys.string = {'1','2','1','2','Esc'};

 s.keys.fingernames = {...
                  'right index finger(1)',...
                  'right middle finger(2)',...
                  'right index finger(1!)', ...
                  'right middle finger(2@)'...
                  };



% event settings
s.events.nTrl    = 60; % number trials
s.events.promptTime = 2; %1.5;
s.events.numExtraBonusNeeded = 0;
s.events.totalScore = 0;

% map settings
s.map.gridSize = 3;
s.map.pixSize = 540;
s.map.moveChoiceMethod = 'random'; % 'nearest' or 'random'
s.map.colors.line = [1 1 1]*255;
s.map.colors.bg = [.4 .4 .4]*255;
s.map.colors.highlight = [.4 .2 .2]*255;
s.map.colors.text = [1 1 1]*255;
s.map.colors.score = [1 1 1]*255;

colSize = round(s.map.pixSize/s.map.gridSize);

% images
if ~(isfield(s, 'images') && isfield(s.images, 'me') && isfield(s.images.me, 'image'))
%     startDir = pwd;
%     cd(fullfile(pwd, 'avatars'));
%     [avfile, avpath] = uigetfile('*.png', 'Choose your avatar');
%     cd(startDir);
    avpath = fullfile(pwd, 'avatars');
    avfile = 'frog.png';
    [s.images.me.image s.images.me.map s.images.me.alpha] = imread(fullfile(avpath, avfile));
    s.images.me.image(:,:,4) = s.images.me.alpha;
    [s.images.me.image, s.images.me.map] = scaleImage(s.images.me.image, .9*colSize);
end
[s.images.reward{1}.image s.images.reward{1}.map s.images.reward{1}.alpha] = imread(fullfile(pwd, 'img', 'goldcoins-1.png'));% 'dollar-sign.png'));%'money-bag-single.png'));
[s.images.reward{2}.image s.images.reward{2}.map s.images.reward{2}.alpha] = imread(fullfile(pwd, 'img', 'goldcoins-5.png'));%'dollar-signs-3.png'));%'money-bag-three.png'));
[s.images.cogreward{1}.image s.images.cogreward{1}.map s.images.cogreward{1}.alpha] = imread(fullfile(pwd, 'img', 'coin-blank.png'));% 'dollar-sign.png'));%'money-bag-single.png'));
[s.images.cogreward{2}.image s.images.cogreward{2}.map s.images.cogreward{2}.alpha] = imread(fullfile(pwd, 'img', 'multi-diamond.png'));%'dollar-signs-3.png'));%'money-bag-three.png'));
[s.images.null.image s.images.null.map s.images.null.alpha] = imread(fullfile(pwd, 'img', 'coin-blank.png'));
[s.images.blank.image s.images.blank.map s.images.blank.alpha] = imread(fullfile(pwd, 'img', 'circle-black.png'));
[s.images.bg.image s.images.bg.map] = imread(fullfile(pwd, 'img', 'map3.png'));
[s.images.progress_bg.image s.images.progress_bg.map s.images.progress_bg.alpha] = imread(fullfile(pwd, 'img', 'hill.png'));

s.images.reward{1}.image(:,:,4) = s.images.reward{1}.alpha;
s.images.reward{2}.image(:,:,4) = s.images.reward{2}.alpha;
s.images.cogreward{1}.image(:,:,4) = s.images.cogreward{1}.alpha;
s.images.cogreward{2}.image(:,:,4) = s.images.cogreward{2}.alpha;
s.images.null.image(:,:,4) = s.images.null.alpha;
s.images.blank.image(:,:,4) = s.images.blank.alpha;
s.images.progress_bg.image(:,:,4) = s.images.progress_bg.alpha;

[s.images.reward{1}.image, s.images.reward{1}.map] = scaleImage(s.images.reward{1}.image, .8*colSize);
[s.images.reward{2}.image, s.images.reward{2}.map] = scaleImage(s.images.reward{2}.image, .8*colSize);
[s.images.cogreward{1}.image, s.images.cogreward{1}.map] = scaleImage(s.images.cogreward{1}.image, .3*colSize);
[s.images.cogreward{2}.image, s.images.cogreward{2}.map] = scaleImage(s.images.cogreward{2}.image, .8*colSize);
[s.images.null.image, s.images.null.map] = scaleImage(s.images.null.image, .8*colSize);
[s.images.blank.image, s.images.blank.map] = scaleImage(s.images.blank.image, .8*colSize);
[s.images.blank_small.image, s.images.blank_small.map] = scaleImage(s.images.blank.image, .2*colSize);
[s.images.bg.image, s.images.bg.map] = scaleImage(s.images.bg.image, s.map.pixSize);
[s.images.progress_bg.image, s.images.progress_bg.map] = scaleImage(s.images.progress_bg.image, .8*s.screen.res(1));
%size(s.images.bg.image)

if strcmp(smmode, 'smcontrol')
    s.images.reward{1} = s.images.blank;
    s.images.reward{2} = s.images.blank;
    s.images.null = s.images.blank;
    s.images.cogreward{1} = s.images.blank_small;
    s.images.cogreward{2} = s.images.blank_small;
end

% sounds
fs = 44100;
s.sounds.useSounds = true;
if s.session.simulate
    s.sounds.useSounds = false;
end

s.sounds.beep.fname = fullfile(pwd, 'sounds', 'beep.wav');
s.sounds.null.fname = fullfile(pwd, 'sounds', 'beep.wav');
s.sounds.reward{1}.fname = fullfile(pwd, 'sounds', 'ding-1.wav');
s.sounds.reward{2}.fname = fullfile(pwd, 'sounds', 'ding-5.wav');
s.sounds.cogreward{1}.fname = fullfile(pwd, 'sounds', 'beep.wav');
s.sounds.cogreward{2}.fname = fullfile(pwd, 'sounds', 'diamond_sound_multi.wav');

[s.sounds.beep.aud, s.sounds.beep.fs] = wavread_(s.sounds.beep.fname);
[s.sounds.null.aud, s.sounds.null.fs] = wavread_(s.sounds.null.fname);
[s.sounds.reward{1}.aud, s.sounds.reward{1}.fs] = wavread_(s.sounds.reward{1}.fname);
[s.sounds.reward{2}.aud, s.sounds.reward{2}.fs] = wavread_(s.sounds.reward{2}.fname);
[s.sounds.cogreward{1}.aud, s.sounds.cogreward{1}.fs] = wavread_(s.sounds.cogreward{1}.fname);
[s.sounds.cogreward{2}.aud, s.sounds.cogreward{2}.fs] = wavread_(s.sounds.cogreward{2}.fname);

[s.sounds.beep.aud, s.sounds.beep.fs] = myresample(s.sounds.beep.aud, s.sounds.beep.fs, fs);
[s.sounds.null.aud, s.sounds.null.fs] = myresample(s.sounds.null.aud, s.sounds.null.fs, fs);
[s.sounds.reward{1}.aud, s.sounds.reward{1}.fs] = myresample(s.sounds.reward{1}.aud, s.sounds.reward{1}.fs, fs);
[s.sounds.reward{2}.aud, s.sounds.reward{2}.fs] = myresample(s.sounds.reward{2}.aud, s.sounds.reward{2}.fs, fs);
[s.sounds.cogreward{1}.aud, s.sounds.cogreward{1}.fs] = myresample(s.sounds.cogreward{1}.aud, s.sounds.cogreward{1}.fs, fs);
[s.sounds.cogreward{2}.aud, s.sounds.cogreward{2}.fs] = myresample(s.sounds.cogreward{2}.aud, s.sounds.cogreward{2}.fs, fs);

s.sounds.beep.buffer =  PsychPortAudio('CreateBuffer', [], s.sounds.beep.aud);
s.sounds.null.buffer =  PsychPortAudio('CreateBuffer', [], s.sounds.null.aud);
s.sounds.reward{1}.buffer =  PsychPortAudio('CreateBuffer', [], s.sounds.reward{1}.aud);
s.sounds.reward{2}.buffer =  PsychPortAudio('CreateBuffer', [], s.sounds.reward{2}.aud);
s.sounds.cogreward{1}.buffer =  PsychPortAudio('CreateBuffer', [], s.sounds.cogreward{1}.aud);
s.sounds.cogreward{2}.buffer =  PsychPortAudio('CreateBuffer', [], s.sounds.cogreward{2}.aud);

if strcmp(smmode, 'smcontrol')
    s.sounds.null = s.sounds.beep;
    s.sounds.reward{1} = s.sounds.beep;
    s.sounds.reward{2} = s.sounds.beep;
    s.sounds.cogreward{1} = s.sounds.beep;
    s.sounds.cogreward{2} = s.sounds.beep;
end


%     PsychPortAudio('RunMode', s.sounds.pahandle, 0);

% movement settings
s.moves.numChoices = 2;

% reward probabilities
s.reward.rewardProb = 0.7; % probability of getting a reward
s.reward.catchProb = 0.3; % probability of a reward trial being a catch (no task)
s.reward.rewardLevProb = [.8 .2]; % low, high rewards WITHIN REWARD TRIALS (excluding catches)
s.reward.displayTime = 0.5; % time to show reward
s.reward.congruentProb = 0.75; 
s.reward.points = [7 19 103];
s.rewards.colors.correct = [1 0.84 0]*255;
s.rewards.colors.incorrect = [1 0 0]*255;
s.reward.cogHighRewProb = 0.25;

% fixation
s.fix.color = [0 0 0];

% flanker task
s.flanker.colors.text = [0 0 0]*255;
s.flanker.colors.correct = s.rewards.colors.correct;
s.flanker.colors.incorrect = s.rewards.colors.incorrect;
s.flanker.displayTime = 0.2;
s.flanker.maxRespTime = 2.0;

% anti task
s.anti.colors.text = [0 0 0]*255;
s.anti.colors.target = [1 1 0]*255;
s.anti.colors.correct = s.rewards.colors.correct;
s.anti.colors.incorrect = s.rewards.colors.incorrect;
s.anti.targetDiamPix = 30;
s.anti.displayTime = 1.0;
s.anti.maxRespTime = 1.0;
s.anti.leftThresh = 100; % x coordinate threshold for a leftward saccade
s.anti.rightThresh = 160;
s.anti.center = 130;


% eye tracking
%IOPort('CloseAll');
s.serial.port = '/dev/ttyS0';
s.serial.configString = 'BaudRate=57600';
s.serial.handle = [];
s.serial.openErrMsg = 'No device';
s.forceReopenWindow = 0;
if exist(s.serial.port, 'file')
    try
        [s.serial.handle, s.serial.openErrMsg] = IOPort('OpenSerialPort', s.serial.port, s.serial.configString);
    catch
        % if there was an error, we probably need to re-open the display
        s.forceReopenWindow = 1;
    end
end
s.serial.xbytes = [5 6];
s.serial.ybytes = [7 9];
s.serial.lineLength = 10;
s.serial


s.parallel.xdat.mapDisplay = 2^0;
s.parallel.xdat.mapChoices = 2^1;
s.parallel.xdat.madeMove = 2^2;
s.parallel.xdat.mapReward = 2^3;
s.parallel.xdat.cogFixation = 2^4;
s.parallel.xdat.cogTask = 2^5;
s.parallel.xdat.cogFeedback = 2^6;


end

function [img, map] = scaleImage(img, maxSize)
    [h,w,dim] = size(img);
    if h>w
        scaleFac = maxSize/h;
    else
        scaleFac = maxSize/w;
    end
    [img, map] = imresize(img, [round(h*scaleFac) round(w*scaleFac)]);
end

function [aud, freq] = myresample(aud, infreq, freq)
    if infreq ~= freq
        % Need to resample this to target frequency 'freq':
        fprintf('Resampling from %i Hz to %i Hz... ', infreq, freq);
        aud = resample(aud, freq, infreq);
    end
    [samplecount, ninchannels] = size(aud); 
    aud = repmat(transpose(aud), 2 / ninchannels, 1);    
    aud = aud*.4;
end
% wavread is removed
function [aud,fs]=wavread_(varargin)
  try
      [aud,fs]=wavread(varargin{:});
  catch
      [aud,fs]=audioread(varargin{:});
  end
end
