subjectname     = input('Enter participant code:', 's');
thedate = date;
outputname = [subjectname,'_',thedate '.xls'];

ListenChar(2); %Characters stop showing up in command window during task
KbName('UnifyKeyNames');
FlushEvents; % release all events in the event queue
while KbCheck; end

outfile = fopen(outputname, 'w');
fprintf(outfile, '\n\nParticipantID: %s\nDate: %s\r\n\r\n',...
        subjectname, thedate);
fprintf(outfile,'Trial\tSound\tResponse\tRT (seconds)\r\n');


if outfile == -1
    fprintf('Couldn''t open output file.\n%s\n', message);
end

WaitTime = 2;  %%%time that task will wait for a response before moving on 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%SCREEN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sca;
close all;

%PsychDefaultSetup(2);
AssertOpenGL;
PsychImaging('PrepareConfiguration');       % Prepare pipeline for configuration.
Screen('Preference', 'SkipSyncTests', 1);

% Get the screen numbers
screens = Screen('Screens');

% Is there an external screen?
screenNumber = max(screens);

white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
[screenXpixels, screenYpixels] =   Screen('WindowSize', window);

ifi = Screen('GetFlipInterval', window);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 33);
% Get the center coordinate of the window

%%%%%%%%%%%%%% SOUNDS START HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%
sound_dir = './Sounds';
seconds_between_sounds = .5; %time between first trial and detection of keypress? I think? 

%sound_file_directory is a variable linking to directory Sounds
sound_file_directory = dir('./Sounds');
%gets rid of .,.., and osxdir from file content  
sound_file_directory = sound_file_directory(arrayfun(@(x) x.name(1), sound_file_directory) ~='.'); 

% Get the names of the files into a cell array of strings, where each string is a name of a file
sound_file_names = {};
for k = 1:length(sound_file_directory)
    sound_file_names = [sound_file_names {sound_file_directory(k).name}];    
end

% Extend the cell array of  file names num_repeat times
num_repeats = 1;
ext_sound_file_names = {};
for k = 1:num_repeats
     ext_sound_file_names = cat(2,ext_sound_file_names, sound_file_names);
end

% Randomize the extended list so we play through it in a different order each time
% Two links: 
%   - https://www.mathworks.com/help/matlab/ref/randperm.html
%   - https://www.mathworks.com/matlabcentral/newsreader/view_thread/239478 (Message: 4 of 6)
%
length_ext_sound_files = length(ext_sound_file_names);
rand_indices = randperm(length_ext_sound_files);

global rand_ext_sound_file_names
rand_ext_sound_file_names = ext_sound_file_names(rand_indices);

DrawFormattedText(window, 'Press F when the sound does not match 2 back, press J when it does match \n Press space key to begin', 'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;

DrawFormattedText(window, '+', 'center', 'center', white);
Screen('Flip', window);
 for k = 1:length(rand_ext_sound_file_names)
    sound_file = strcat(sound_dir,'/', rand_ext_sound_file_names{k});
    [y, Fs] = audioread(sound_file);
    sound(y,Fs);
    ExpStartTime = GetSecs;
    pause(seconds_between_sounds)
    disp(rand_ext_sound_file_names{k}) %displays order of soundfiles played
    letter = rand_ext_sound_file_names{k};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TrialStartTime = GetSecs;
    keyIsDown = 0;
    FlushEvents; % release all events in the event queue
    while KbCheck; end
    while GetSecs < TrialStartTime + WaitTime
        [keyIsDown, secs, keycode] = KbCheck;
        % this will keep checking the keyboard until Waittime is exceeded

        if keyIsDown % if a key is pressed figure out what it was and when it was
            response = KbName(keycode);
            resptime = secs - TrialStartTime; %Calculate RT from TrialStartTime
            keyIsDown = 0;     FlushEvents;
            break 
            % this means you break out of the while loop 
            % so you don't wait any longer after key is pressed
        else % if no key was pressed
            response = 'none';
            resptime = 999;
            FlushEvents;
        end
    keyIsDown = 0;     
    FlushEvents;
    end;
    while KbCheck; end 
    % Check the response and display message accordingly
    if response == 'none' % if no key was pressed
        disp (['No key press was detected in ' num2str(WaitTime) ' seconds'])
        
    else % if a key was pressed, display the response and reaction time
        disp (['The key was: ' response]);
        disp (['The time was: ' num2str(resptime)]);
        fprintf(outfile, '%d\t%s\t%s\t%f\r\n', k,sound_file, response, resptime);
    end
    pause(seconds_between_sounds)

 end
 KbStrokeWait;
 ListenChar(0) %Characters do show up in command window 
    % write into text file
    fprintf(outfile, '%d\t%s\t%s\t%f\r\n', k,sound_file,response, resptime);
    sca;