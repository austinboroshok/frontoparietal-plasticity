%%
dat.subj     = input('Enter participant code:', 's');
outputname = [dat.subj '.xls'];
thedate = date;

outfile = fopen(outputname, 'w');
fprintf(outfile, '\n\nParticipantID: %s\nDate: %s\r\n\r\n',...
        dat.subj, thedate);
fprintf(outfile,'Trial\tResponse\tRT (seconds)\r\n');


if outfile == -1
    fprintf('Couldn''t open output file.\n%s\n', message);
end

mkdir('data',dat.subj);


% Clears  screen 
sca;
close all;
clearvars;

% Setup Psychtoolbox
PsychDefaultSetup(2);


KbName('UnifyKeyNames')
spaceKey= KbName('space'); escKey = KbName('ESCAPE');
corrkey = [80, 79];
   
% Get the screen numbers
screens = Screen('Screens');

% Is there an external screen?
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] =   Screen('WindowSize', window);

ifi = Screen('GetFlipInterval', window);

%LineBlends
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


DrawFormattedText(window, 'You will do the following:     Press space key to begin', 'center', 'center', white);
Screen('Flip', window);
keyIsDown=0;
while 1
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(spaceKey)
            break ;
        elseif keyCode(escKey)
            ShowCursor;
            fclose('all');
            Screen('CloseAll');
            return;
        end
    end
end
            


% Text that appears underneath our dear plus sign. 
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);
DrawFormattedText(window, 'Press the space bar if the letter you hear matches two back ', 'center', screenYpixels * 0.75, white); 
% Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Plus sign (or 'cross' in this case) size
fixCrossDimPix = 40;

 
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our plus
lineWidthPix = 4;

% Draw the plus in white, set it to the center of our screen
Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2); 

   
% Flip to the second screen
Screen('Flip', window);
pause(2);
rename_me()

% Ends task after loop is done ...
KbStrokeWait;


% Clears screen
sca;