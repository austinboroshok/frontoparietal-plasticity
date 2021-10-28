function dat = run_introduction(varargin)
%
% test nback memory at a range of nbacks
%
% provide a string to specify the screen that is being used (from
% screen_info), or else you will be prompted for it

addpath([ pwd '/helper_functions']);   % add path to helper functions

% GET EXPERIMENT VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select screen, if not provided
dat.scr = select_screen(varargin);

% find out participant code and whether this is a pre- or post-test run
dat.subj        = input('Enter participant code:','s');
 
% if a pre-test, set up initial pre-test variables
dat.test_type           = 'introduction';
dat.experiment_file     = 'introduction.txt';
%dat.experiment_file     = 'debugging.txt';
dat.sound_set           = 'Introduction_Sounds';
dat.trial_sec           = 2;

dat.feedback    = 1; % provide visual
do_plot         = 1; % plot results immediately

% get start time for file names
dat.timeNow     = datestr(clock,'mm_dd_yy_HHMMSS');
dat.fileName    = [ dat.subj '_' dat.test_type '_' dat.timeNow '.mat'];

% run PTB commands in try/catch loop
try
    
    % SET UP SCREEN, STIMULUS, WINDOW, KEYS %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [dat.scr, w, ~]         = screen_setup(dat.scr);        % PTB window
    [dat,allsounds]         = stimulus_setup(dat);          % load info for audio files
    dat                     = trial_setup_testing(dat);     % trial properties
    [dat,keys]              = keys_setup(dat);              % key responses
    outfile                 = output_setup(dat.subj,dat.fileName); % open xls file for writing results
    dat.start               = GetSecs;

    %fopen(outputname, 'w');
    
    % DRAW INTRO SCREEN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Screen(w,'TextSize',dat.scr.fontSize);
    
    Screen('FillRect', w, [0 0 0]);
    DrawFormattedText(w, 'During each trial, listen for whether each syllable matches the syllable 2,3, or 4 syllables back', 'center', dat.scr.y_center_pix - dat.scr.heightPix/2.25, [255 255 255]);
    DrawFormattedText(w, 'Press J when the sound does not match back, press F when it does match', 'center', dat.scr.y_center_pix - dat.scr.heightPix/2.5, [255 255 255]);
    DrawFormattedText(w, 'Press space bar to start', 'center', dat.scr.y_center_pix + dat.scr.heightPix/4, [255 255 255]);
    
    Screen('Flip',  w, [], 1);
    KbWait(-3);
    WaitSecs(0.25);			% slight delay before starting
    
    % RUN TRIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Perform basic initialization of the sound driver:
    InitializePsychSound;

    % load dummy sound to get sampling rate and number of channels
    [y, Fs]     = audioread(dat.trials.sound_file{1});
    nrchannels = size(y',1);
    pahandle = PsychPortAudio('Open', [], [], 0, Fs, nrchannels);

    currentBlock = 0;
    
    for trial = 1:length(dat.trials.nback)                   % for each trial
        
        % trial info
        nback           = dat.trials.nback(trial);      % nback block
        block           = dat.trials.block(trial);
        sound_file      = dat.trials.sound_file{trial};     % index for syllable sound
        sound_index     = dat.trials.sound_index(trial); 
        
        % display info in matlab prompt for debugging
        display(['nback = ' num2str(nback) ' ... file = ' sound_file]);
        
        % indicate the start of a new block if needed
        if block > currentBlock
            
            WaitSecs(0.25);
            Screen('FillRect', w, [0 0 0]);
            DrawFormattedText(w, ['NBACK = ' num2str(nback) ], 'center', dat.scr.y_center_pix - dat.scr.heightPix/4, [255 255 255]);
            DrawFormattedText(w, 'Press space bar to start', 'center', dat.scr.y_center_pix + dat.scr.heightPix/4, [255 255 255]);
            Screen('Flip',  w, [], 1);
            KbWait(-3);
            WaitSecs(0.25);			% slight delay before starting
            
            currentBlock = block;
            blockTrial = 1;
            
        end
        
        % start trial with blank screen
        Screen('FillRect', w, [0 0 0]);
        draw_response_screen(w,dat,trial);
        
        
        % play syllable
        %[y, Fs]     = audioread(sound_file);
        %PsychPortAudio('FillBuffer', pahandle, y');
        %t1 = PsychPortAudio('Start', pahandle, 1, 0, 0);
        %sound(allsounds(sound_index).y,allsounds(sound_index).Fs);
        
        PsychPortAudio('FillBuffer', pahandle, allsounds(sound_index).y');
        t1 = PsychPortAudio('Start', pahandle);
        PsychPortAudio('Stop', pahandle, 1);
        
        TrialStartTime = GetSecs;
        
        % prompt for response
        draw_response_screen(w,dat,trial);
        
        % get subject responses
        while GetSecs < TrialStartTime + dat.trial_sec
            
            %if blockTrial > nback
                % check for response
                [dat,keys] = keys_get_response_introduction(w,keys,dat,trial,blockTrial,nback,sound_index,TrialStartTime);
            %end

        end
        % if they didn't respond, all response fields should be nan
        
        % record whether this was an nback trial or not for computing performance
        if blockTrial > nback
            
            if sound_index == dat.trials.sound_index(trial-nback)
                dat.trials.nBackTrue(trial) = 1;
            elseif ~(sound_index == dat.trials.sound_index(trial-nback))
                dat.trials.nBackTrue(trial) = 0;
            end
            
        elseif blockTrial <= nback
            
            dat.trials.nBackTrue(trial) = 0;
            
        end
        

        keys.isDown = 0;
        
        if keys.killed
            break
        end
        
        blockTrial = blockTrial + 1;
        
        % store info for this trial into csv
        fprintf(outfile, '%d,%d,%s,%d,%d,%d,%d\r\n', trial,nback,...
            strcat(dat.sound_dir,'/', dat.trials.sound_file{trial}),dat.trials.resp(trial), dat.trials.respTime(trial), dat.trials.nBackTrue(trial), dat.trials.isCorrect(trial));
        
    end
    
    % aggregate and save data structures
    dat.keys    = keys;
    dat.end     = GetSecs;
    fclose(outfile);
    store_results(dat);
    
    % exit
    Screen('FillRect', w, [0 0 0]);
    DrawFormattedText(w, 'Done', 'center', 'center', [255 255 255]);
    Screen('Flip',  w, [], 1);
    WaitSecs(2);
    
    PsychPortAudio('Close');
    
    cleanup(0,dat);
    
    % draw and save plot if requested
    if do_plot && trial > 1
        plot_results_testing(dat);
        saveas(gcf,['../data/' dat.subj '/' strrep(dat.fileName,'mat','pdf')]);
    end
    
    cleanup(0,dat);
    
    %draw_response_screen(w,dat,0);
    
catch
    
    cleanup(0,dat);
    psychrethrow(psychlasterror);
    
end