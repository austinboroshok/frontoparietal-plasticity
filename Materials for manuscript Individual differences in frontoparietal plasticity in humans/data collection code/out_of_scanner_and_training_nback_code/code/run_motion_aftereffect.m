function run_motion_aftereffect(varargin)
%
% test motion direction discrimination at a range of directions and
% coherences
%
% provide a string to specify the screen that is being used (from
% screen_info), or else you will be prompted for it

addpath([ pwd '/helper_functions_motion']);   % add path to helper functions
%addpath([pwd '/ShadlenDotsX' ]);

% GET EXPERIMENT VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select screen, if not provided
dat.scr = select_screen(varargin);

% find out participant code
dat.subj        = input('Enter participant code:','s');

dat.test_type            = 'motion_aftereffect';
dat.duration             = 30;
dat.repeats              = 10;
do_plot         = 1; % plot results immediately

% get start time for file names
dat.timeNow     = datestr(clock,'mm_dd_yy_HHMMSS');
dat.fileName    = [ dat.subj '_motion_aftereffect_' dat.timeNow '.mat'];

% run PTB commands in try/catch loop
try
    
    % SET UP SCREEN, STIMULUS, WINDOW, KEYS %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [dat.scr, w, ~]         = screen_setup(dat.scr);        % PTB window
    
    outfile                 = output_setup(dat.subj,dat.fileName); % open xls file for writing results
    
    [dat,stim] = pregenerate_motion_aftereffect_stimulus(dat);
    
    %screenInfo              = createScreenInfoForShadlen(dat,w); % screen info struct for Shadlen code
    dat.start               = GetSecs;
    
    % DRAW INTRO SCREEN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Screen(w,'TextSize',dat.stm.fontSize);
    
    Screen('FillRect', w, [0 0 0]);
    DrawFormattedText(w, 'Fixate the center of the screen and try to minimize blinks and eye/head movements', 'center', dat.scr.y_center_pix - dat.scr.heightPix/2.25, [255 255 255]);
    DrawFormattedText(w, 'When the fixation dot changes color, press the space bar', 'center', dat.scr.y_center_pix - dat.scr.heightPix/2.5, [255 255 255]);
    DrawFormattedText(w, 'Hold it until you see no more motion in the lines', 'center', dat.scr.y_center_pix - dat.scr.heightPix/2.75, [255 255 255]);
    DrawFormattedText(w, 'Press space bar to start', 'center', dat.scr.y_center_pix + dat.scr.heightPix/4, [255 255 255]);
    
    Screen('DrawDots',w,[dat.scr.x_center_pix dat.scr.y_center_pix], 20, [255 0 0], [], 2)
    
    Screen('Flip',  w, [], 1);
    KbWait(-3);
    WaitSecs(1);
    
    
    % RUN TRIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for t = 1:dat.repeats                   % for each trial
        
        trialstartTime = GetSecs;
        
        Screen('FillRect', w, [0 0 0]);
        
        stim.lines_orig = stim.lines;
        
        while GetSecs - trialstartTime <= dat.duration
            
            Screen('FillRect', w, [0 0 0]);
            
            for x = 1:dat.stm.num_bars

                if x == 1 || x == 3
                    stim.lines(x).coords(1,:) = stim.lines(x).coords(1,:) + dat.stm.dotSpeedPixPerFrame;
                    stim.lines(x).coords(1,stim.lines(x).coords(1,:) > dat.scr.widthPix) = stim.lines(x).coords(1,stim.lines(x).coords(1,:) > dat.scr.widthPix) - dat.scr.widthPix;
                else
                    stim.lines(x).coords(1,:) = stim.lines(x).coords(1,:) - dat.stm.dotSpeedPixPerFrame;
                    stim.lines(x).coords(1,stim.lines(x).coords(1,:) < 1) = dat.scr.widthPix - stim.lines(x).coords(1,stim.lines(x).coords(1,:) < 1);
                    
                end
                Screen('DrawLines', w, stim.lines(x).coords, 1, [255 255 255]);

            end
            
            Screen('DrawDots',w,[dat.scr.x_center_pix dat.scr.y_center_pix], 20, [255 0 0], [], 2);
            
            Screen('Flip',  w, [], 1);
            
        end
        
        Screen('FillRect', w, [0 0 0]);
        
        %for x = 1:dat.stm.num_bars
            Screen('DrawLines', w, [stim.lines_orig(1).coords(1,:) ; repmat([0 dat.scr.heightPix],1,length(stim.locs)/2)], 1, [255 255 255]);
        %end
        
        
        Screen('DrawDots',w,[dat.scr.x_center_pix dat.scr.y_center_pix], 20, [0 255 0], [], 2);
        
        Screen('Flip',  w, [], 1);
        
        stopTime = GetSecs;
        [pressTime, ~, ~] = KbWait(-3,0);
        [liftTime, ~, ~] = KbWait(-3,1);
        
        pressDuration = liftTime-pressTime;
        
        display( num2str(pressDuration,2));
        
        % store info for this trial into csv
        fprintf(outfile, '%d,%.2f,%.2f\r\n', t,pressTime-stopTime,pressDuration);
        
        if t <dat.repeats
        Screen('FillRect', w, [0 0 0]);
        DrawFormattedText(w, 'Fixate the center of the screen and try to minimize blinks and eye/head movements', 'center', dat.scr.y_center_pix - dat.scr.heightPix/2.25, [255 255 255]);
        DrawFormattedText(w, 'When the fixation dot changes color, press the space bar', 'center', dat.scr.y_center_pix - dat.scr.heightPix/2.5, [255 255 255]);
        DrawFormattedText(w, 'Hold it until you see no more motion in the lines', 'center', dat.scr.y_center_pix - dat.scr.heightPix/2.75, [255 255 255]);
        DrawFormattedText(w, 'Press space bar to start', 'center', dat.scr.y_center_pix + dat.scr.heightPix/4, [255 255 255]);
        
        Screen('DrawDots',w,[dat.scr.x_center_pix dat.scr.y_center_pix], 20, [255 0 0], [], 2)

        Screen('Flip',  w, [], 1);
        KbWait(-3);
        WaitSecs(1);
        
        end
        
        
    end
    
    % aggregate and save data structures
    %dat.keys    = keys;
    dat.end     = GetSecs;
    store_results(dat);
    
    % exit
    Screen('FillRect', w, [0 0 0]);
    DrawFormattedText(w, 'Done', 'center', 'center', [255 255 255]);
    Screen('Flip',  w, [], 1);
    WaitSecs(2);
    
    cleanup(0,dat);
    
    %     % draw and save plot if requested
    %     if do_plot && t > 1
    %         plot_results_testing(dat,0);
    %         saveas(gcf,['../data/' dat.subj '/' strrep(dat.fileName,'mat','pdf')]);
    %     end
    
catch
    
    cleanup(0,dat);
    psychrethrow(psychlasterror);
    
end



