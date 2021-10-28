function     draw_fixation_circle(w,dat)
%
%

rectt   =   CenterRectOnPoint([0 0 2*dat.stm.fixationRadiusPix 2*dat.stm.fixationRadiusPix], dat.scr.widthPix/2, dat.scr.heightPix/2);
Screen( 'FillOval', w, repmat(dat.stm.fixationIntensity,1,3),  rectt );