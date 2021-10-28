function screenInfo = createScreenInfoForShadlen(dat,w)
% screen info struct for Shadlen code

screenInfo.curWindow    = w;
screenInfo.center       = [dat.scr.widthPix dat.scr.heightPix]/2;
screenInfo.ppd          = 1/(dat.scr.pix2arcmin/60);
screenInfo.monRefresh   = dat.scr.frameRate;
screenInfo.dontclear    = 0;
screenInfo.rseed        = dat.scr.rseed;