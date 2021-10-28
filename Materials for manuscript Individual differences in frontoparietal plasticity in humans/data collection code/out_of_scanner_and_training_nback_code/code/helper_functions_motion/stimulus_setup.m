function [dat] = stimulus_setup(dat)
%
% define features of experimental stimulus


%  SCREEN  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dat.scr.cm2pix              = dat.scr.widthPix/dat.scr.widthCm;                           % conversion for cm to pixels
dat.scr.pix2arcmin          = 2*60*atand(0.5/(dat.scr.viewDistCm*dat.scr.cm2pix));          % conversion from pixels to arcminutes
display(['1 pixel = ' num2str(dat.scr.pix2arcmin,2) ' arcmin']);

dat.scr.x_center_pix        = dat.scr.widthPix/2;     % l/r screen center
dat.scr.y_center_pix        = dat.scr.heightPix/2;    % u/d screen center


%  STIMULUS PROPERTIES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dat.dotSpeedDegPerSec   = 8;
dat.dotSizeDeg          = 0.1;
dat.stimRadDeg          = 12;

% LUT for dot directions
dat.angles      = [90 270 180 0 45 135 225 315];
dat.angle_terms = {'up','down','left','right','up right','up left','down left','down right'};

% overwritten by Shadlen code
%dat.dotDensity          = 4;
%stm.wlevel          = 255;       % white
%stm.glevel          = 0;         % gray
%stm.blevel          = 0;         % black

stm.dotSpeedPixPerSec       = (dat.dotSpeedDegPerSec*60)/dat.scr.pix2arcmin;
stm.dotSpeedPixPerFrame     = stm.dotSpeedPixPerSec/dat.scr.frameRate;
stm.stimRadPix              = round((60*dat.stimRadDeg)/dat.scr.pix2arcmin);    % dot field radius in pixels
stm.dotSizePix              = (dat.dotSizeDeg*60)/dat.scr.pix2arcmin;           % dot diameter in pixels, PTB DrawDots seems to round this down to the nearest pixel

% report how much each dot moves per frame
display(['dots diameter = ' num2str(stm.dotSizePix,2) ' pix and move ' num2str(stm.dotSpeedPixPerFrame,2) ' pix per frame']);

%  FIXATION  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stm.fixationRadiusDeg   = 1;
stm.fixationRadiusPix   = (60*stm.fixationRadiusDeg)/dat.scr.pix2arcmin;
stm.fixationRadiusSqPix = stm.fixationRadiusPix^2;

stm.fixationDotRadiusDeg = 0.125;
stm.fixationDotRadiusPix = (60*stm.fixationDotRadiusDeg)/dat.scr.pix2arcmin;

stm.fontSize = 32;

stm.fixationIntensity = 172;
stm.letterIntensityDifference  = dat.scr.letter_intensity_difference;

%% SOUND %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% neutral sound
cf = 1000;                  % carrier frequency (Hz)
sf = 22050;                 % sample frequency (Hz)
d = 0.1;                    % duration (s)
n = sf * d;                 % number of samples
s = (1:n) / sf;             % sound data preparation
s = sin(2 * pi * cf * s);   % sinusoidal modulation
stm.sound.s = s;
stm.sound.sf = sf;

% happy sound
cf = 2000;                  % carrier frequency (Hz)
sf = 22050;                 % sample frequency (Hz)
d = 0.1;                    % duration (s)
n = sf * d;                 % number of samples
s = (1:n) / sf;             % sound data preparation
s = sin(2 * pi * cf * s);   % sinusoidal modulation
stm.sound.sYes = s;
stm.sound.sfYes = sf;

% sad sound
cf = 250;                  % carrier frequency (Hz)
sf = 22050;                 % sample frequency (Hz)
d = 0.1;                    % duration (s)
n = sf * d;                 % number of samples
s = (1:n) / sf;             % sound data preparation
s = sin(2 * pi * cf * s);   % sinusoidal modulation
stm.sound.sNo = s;
stm.sound.sfNo = sf;

dat.stm = stm;


