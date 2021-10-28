function draw_response_screen_moa(w,dat,direction)

draw_fixation_circle(w,dat.scr.widthPix,dat.scr.heightPix,dat.stm.fixationRadiusPix);
DrawFormattedText(w, '+', 'center', 'center', [255 255 255]);

%DrawFormattedText_mod(w, 'Press 1', 'center', dat.scr.y_center_pix-150, [255 255 255],-200);
draw_arrow(w, [dat.scr.x_center_pix-200 dat.scr.y_center_pix], 180 - direction, [255 255 255], [30 30 100 10]);

%DrawFormattedText_mod(w, 'Press 2', 'center', dat.scr.y_center_pix-150, [255 255 255],200);
%draw_arrow(w, [dat.scr.x_center_pix+200 dat.scr.y_center_pix], 180 - dat.directions(2), [255 255 255], [30 30 100 10]);

DrawFormattedText(w, 'coherent motion in this direction?', 'center', dat.scr.y_center_pix - 200, [255 255 255]);

DrawFormattedText(w, 'Respond 1 to increase, 2 to decrease, space to repeat', 'center', dat.scr.y_center_pix + 100, [255 255 255]);

Screen('Flip',  w, [], 1);