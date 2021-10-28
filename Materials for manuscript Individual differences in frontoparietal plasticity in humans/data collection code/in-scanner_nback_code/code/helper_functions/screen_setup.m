function [scr, w, winRect] = screen_setup(scr)
%
% open and set up PTB screen window

PsychImaging('PrepareConfiguration');       % Prepare pipeline for configuration.

rseed = sum(100*clock); % Seed random number generator
rng(rseed,'v5uniform'); % v5 random generator
scr.rseed = rseed;

% timing test
if scr.skipSync
    Screen('Preference', 'SkipSyncTests', 1);
else
    Screen('Preference', 'SkipSyncTests', 0);
end

% open black screen with 2 buffers
% switch commenting on these two lines to open small window for debugging
[w, winRect] = Screen('OpenWindow', scr.screenNumber, [0,0,0],[],[], 2);
%[w, winRect] = Screen('OpenWindow', scr.screenNumber, [0,0,0],[0 0 100 100],[], 2);
    
% Enable alpha blending with proper blend-function. We need it for drawing
% of smoothed points.

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%Screen('TextFont', w, char('Andale Mono'));

%Screen('BlendFunction', w, GL_ONE, GL_ONE);

% flip it
Screen('Flip', w);

% get frame rate and resolution info
scr.frameRate   = Screen('NominalFrameRate',w);
scr.widthPix    = RectWidth(Screen('Rect', scr.screenNumber));
scr.heightPix   = RectHeight(Screen('Rect', scr.screenNumber));

scr.x_center_pix        = scr.widthPix/2;     % l/r screen center
scr.y_center_pix        = scr.heightPix/2;    % u/d screen center


if scr.frameRate == 0
    scr.frameRate = 60;
    display(['Unable to query frame rate, assuming 60 Hz -- double check this yourself!']);
else
    display(['Frame Rate = ' num2str(scr.frameRate) 'Hz']);
end

% set window to priority
priorityLevel = MaxPriority(w,'KbCheck');
Priority(priorityLevel);

% Disable key output to Matlab window:
ListenChar(2);