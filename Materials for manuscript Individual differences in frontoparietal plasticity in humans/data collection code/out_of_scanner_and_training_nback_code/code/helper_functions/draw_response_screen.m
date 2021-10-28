function draw_response_screen(w,dat,t)

DrawFormattedText(w, [num2str(dat.trials.nback(t)) ' back?'], 'center', dat.scr.y_center_pix - dat.scr.y_center_pix/2, [255 255 255]);

DrawFormattedText(w, ['YES (' dat.scr.response_mapping{1} ')'], 'center', dat.scr.y_center_pix - dat.scr.y_center_pix/8, [255 255 255]);
DrawFormattedText(w, ['NO (' dat.scr.response_mapping{2} ')'], 'center', dat.scr.y_center_pix + dat.scr.y_center_pix/8, [255 255 255]);

% if t > 0
% DrawFormattedText(w, ['trial ' num2str(t) '/' num2str(length(dat.trials.trialnum)) ], 'center', dat.scr.y_center_pix + dat.scr.heightPix/4, [255 255 255]);
% end

Screen('Flip',  w, [], 1);