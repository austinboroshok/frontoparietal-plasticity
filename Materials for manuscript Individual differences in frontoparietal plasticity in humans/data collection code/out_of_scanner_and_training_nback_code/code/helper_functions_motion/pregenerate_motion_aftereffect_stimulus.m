function [dat,stim] = pregenerate_motion_aftereffect_stimulus(dat)
%
%

dat.cycle_width_deg = 1;
dat.duty_cycle = 0.66;
dat.bar_width_deg = dat.duty_cycle*dat.cycle_width_deg;
dat.bar_spacing_deg = (1-dat.duty_cycle)*dat.cycle_width_deg;

%factors of screen size
N=dat.scr.widthPix;
K=1:dat.scr.widthPix;
D = K(rem(N,K)==0);

% dat.stm.duration_sec = dat.duration;
% dat.stm.bar_width_deg = 0.5;
% dat.stm.bar_spacing_deg = 0.25;
% dat.stm.bar.duty_cycle = 100*dat.stm.bar_width_deg/(dat.stm.bar_width_deg+dat.stm.bar_spacing_deg);
dat.stm.bar_speed_deg_sec = 2;
dat.stm.num_bars = 4;

dat.stm.fontSize = 32;
dat.scr.x_center_pix        = dat.scr.widthPix/2;     % l/r screen center
dat.scr.y_center_pix        = dat.scr.heightPix/2;    % u/d screen center
dat.scr.cm2pix              = dat.scr.widthPix/dat.scr.widthCm;                           % conversion for cm to pixels
dat.scr.pix2deg          = 2*atand(0.5/(dat.scr.viewDistCm*dat.scr.cm2pix));          % conversion from pixels to arcminutes
display(['1 pixel = ' num2str(dat.scr.pix2deg,2) ' deg']);

dat.bar_width_pix = round(dat.bar_width_deg/dat.scr.pix2deg);
dat.bar_spacing_pix = round(dat.bar_spacing_deg/dat.scr.pix2deg);
dat.cycle_width_pix = dat.bar_width_pix+dat.bar_spacing_pix;

tmp = D(abs(dat.cycle_width_pix - D) == min(abs(dat.cycle_width_pix - D)));
tmp = tmp(1);

dat.cycle_width_pix = tmp;
dat.bar_width_pix = floor(dat.duty_cycle*dat.cycle_width_pix);
dat.bar_spacing_pix = ceil((1-dat.duty_cycle)*dat.cycle_width_pix);

% needs to be a round number!
dat.stm.cycles_per_screen = dat.scr.widthPix/dat.cycle_width_pix;

dat.stm.dotSpeedPixPerSec       = (dat.stm.bar_speed_deg_sec)/dat.scr.pix2deg;
dat.stm.dotSpeedPixPerFrame     = round(dat.stm.dotSpeedPixPerSec/dat.scr.frameRate);

%dat.stm.bar_width_pix              = round((dat.stm.bar_width_deg)/dat.scr.pix2deg);           % dot diameter in pixels, PTB DrawDots seems to round this down to the nearest pixel
%dat.stm.bar_spacing_pix              = round((dat.stm.bar_spacing_deg)/dat.scr.pix2deg);

dat.stm.bar_height_pix = dat.scr.heightPix/dat.stm.num_bars;


%cycle_size = dat.scr.widthPix/dat.stm.cycles_per_screen;


stim.locs = repmat([ones(1,dat.bar_width_pix) zeros(1,dat.bar_spacing_pix)],1,dat.stm.cycles_per_screen);
stim.locs = sort(repmat(find(stim.locs),1,2));

%stim.locs = stim.locs(stim.locs <= dat.scr.widthPix);

for x = 1:dat.stm.num_bars
    %stim.lines(x).coords = [mod(stim.locs + (x*[dat.bar_width_pix + dat.bar_spacing_pix])/2, dat.scr.widthPix) ; repmat([(x-1)*dat.stm.bar_height_pix x*dat.stm.bar_height_pix],1,length(stim.locs)/2)];
    stim.lines(x).coords = [ stim.locs + (dat.cycle_width_pix/2); repmat([(x-1)*dat.stm.bar_height_pix x*dat.stm.bar_height_pix],1,length(stim.locs)/2)];
end

% stim.locs = repmat([1 zeros(1,dat.stm.bar_spacing_pix + dat.stm.bar_width_pix)],1,dat.stm.cycles_per_screen);
% stim.locs = sort(repmat(find(stim.locs),1,2));
% stim.locs = stim.locs(stim.locs <= dat.scr.widthPix);
% 
% for x = 1:dat.stm.num_bars
%     stim.lines(x).coords = [mod(stim.locs + (x*[dat.stm.bar_width_pix + dat.stm.bar_spacing_pix])/2, dat.scr.widthPix) ; repmat([(x-1)*dat.stm.bar_height_pix x*dat.stm.bar_height_pix],1,length(stim.locs)/2)];
% end

%sca
%keyboard
%stim = square(linspace(0,2*pi*dat.stm.cycles_per_screen,dat.scr.widthPix),dat.stm.bar.duty_cycle);

%stim = repmat(tmp,dat.stm.bar_height_pix,1);