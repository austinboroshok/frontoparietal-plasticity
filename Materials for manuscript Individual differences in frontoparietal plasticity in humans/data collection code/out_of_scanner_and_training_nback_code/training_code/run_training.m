function dat = run_training(varargin)
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

%dat             = load_pretest_file(dat.subj);
dat.test_type = 'training';

dat.nbacks          = 35;          % number of nbacks
dat.first_nback     = 2;        % starter nback
 
dat.repeats         = 24;    % number of syllables in a sequence

dat.trial_sec       = 2;
%dat.sound_set        = 'Test_Sounds'; % should be Real_Sounds for experiment
dat.sound_set        = 'Real_Sounds';

dat.feedback    = 0; % provide auditory feedback? currently does nothing
do_plot         = 0; % plot results immediately
dat.breakIntervalSec = 300; %interval between breaks 

% get start time for file names
dat.timeNow     = datestr(clock,'mm_dd_yy_HHMMSS');
dat.fileName    = [ dat.subj '_' dat.test_type '_' dat.timeNow '.mat'];

% run PTB commands in try/catch loop
try
    
    % SET UP SCREEN, STIMULUS, WINDOW, KEYS %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [dat.scr, w, ~]         = screen_setup(dat.scr);        % PTB window
    [dat,allsounds]         = stimulus_setup(dat);          % load info for audio files
    dat                     = trial_setup_training(dat);     % trial properties
    [dat,keys]              = keys_setup(dat);              % key responses
    outfile                 = output_setup(dat.subj,dat.fileName); % open xls file for writing results
    dat.start               = GetSecs;

    %fopen(outputname, 'w');
    
    % DRAW INTRO SCREEN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Screen(w,'TextSize',dat.scr.fontSize);
    
    Screen('FillRect', w, [0 0 0]);
    DrawFormattedText(w, 'During each trial, listen for whether each syllable matches the syllable 2,3, or 4 syllables back', 'center', dat.scr.y_center_pix - dat.scr.heightPix/2.25, [255 255 255]);
    DrawFormattedText(w, 'Press F when the sound does not match back, press J when it does match', 'center', dat.scr.y_center_pix - dat.scr.heightPix/2.5, [255 255 255]);
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

    % intialize block trial counter
    blockTrial = 1;
    currentBlock = 1;

    breaktime = GetSecs;
    
    for trial = 1:length(dat.trials.block)                   % for each trial
        
        % trial info
        nback           = dat.trials.nback(trial);      % nback block
        block           = dat.trials.block(trial);
        sound_index     = dat.trials.sound_index(trial);     % index for syllable sound
        
        % display info in matlab prompt for debugging
        display(['nback = ' num2str(nback) ' ... letter = ' dat.sound_file_names{sound_index}]);
        
        % start trial with blank screen
        Screen('FillRect', w, [0 0 0]);
        draw_response_screen(w,dat,trial);
        
        
        % play syllable
        %sound_file  = strcat(dat.sound_dir,'/', dat.sound_file_names{letter});
        %[y, Fs]     = audioread(sound_file);
        %PsychPortAudio('FillBuffer', pahandle, y');
        %t1 = PsychPortAudio('Start', pahandle, 1, 0, 0);
        %sound(y,Fs);
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
                [dat,keys] = keys_get_response_testing(w,keys,dat,trial,blockTrial,nback,sound_index,TrialStartTime);
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
        

        
        % increment block trial counter
        blockTrial = blockTrial + 1;
        
        % store info for this trial into csv
        fprintf(outfile, '%d,%d,%s,%d,%d,%d,%d\r\n', trial,nback,...
            strcat(dat.sound_dir,'/', dat.sound_file_names{sound_index}),dat.trials.resp(trial), dat.trials.respTime(trial),dat.trials.nBackTrue(trial),dat.trials.isCorrect(trial));
        
        % set up next block if needed
        if blockTrial > dat.repeats && trial <= length(dat.trials.block)
            
            % calculate percent correct for the previous block
            trial_inds          = find(dat.trials.block == currentBlock);
            percent_correct     = 100*sum(dat.trials.isCorrect(trial_inds) == 1)/numel(trial_inds);
            
            display(['BLOCK ' num2str(block) 'completed ... percent correct = ' num2str(percent_correct)]);
            
            % adjust nback
            if percent_correct >= 90
                dat.trials.nback = [dat.trials.nback repmat(nback+1,1,dat.repeats)];
            elseif percent_correct <= 70 && nback > dat.first_nback
                dat.trials.nback = [dat.trials.nback repmat(nback-1,1,dat.repeats)];
            else
                dat.trials.nback = [dat.trials.nback repmat(nback,1,dat.repeats)];
            end
            
            % generate list of syllables with 3 or 4 targets
            [sound_indices, targets] = generate_nback(dat.trials.nback(end),dat.repeats,dat.num_syls);
            
            dat.trials.sound_index      = [dat.trials.sound_index sound_indices];
            dat.trials.sound_file       = [dat.trials.sound_file {dat.sound_file_names{sound_indices}}];
            dat.trials.targets          = [dat.trials.targets targets];

         if GetSecs-breaktime > dat.breakIntervalSec
            WaitSecs(0.25);
            Screen('FillRect', w, [0 0 0]);
            DrawFormattedText(w, ['Take a 2 minute break, task will resume automatically'], 'center', dat.scr.y_center_pix - dat.scr.heightPix/4, [255 255 255]);
            DrawFormattedText(w, '+', 'center', 'center', [255 255 255]);
            Screen('Flip', w, [], 1);
            %KbWait(-3);
            WaitSecs(120); 
            
            breaktime = GetSecs; 
        end 
            
            % indicate the start of a new block
            WaitSecs(0.25);
            Screen('FillRect', w, [0 0 0]);
            DrawFormattedText(w, ['NBACK = ' num2str(dat.trials.nback(end)) ], 'center', dat.scr.y_center_pix - dat.scr.heightPix/4, [255 255 255]);
            DrawFormattedText(w, 'Press space bar to start', 'center', dat.scr.y_center_pix + dat.scr.heightPix/4, [255 255 255]);
            Screen('Flip',  w, [], 1);
            KbWait(-3);
            WaitSecs(0.25);			% slight delay before starting
            
            % restart block trials counter
            blockTrial = 1;
            currentBlock = currentBlock + 1;
            
            
    
        end
        


        
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
        plot_results_training(dat);
        saveas(gcf,['../data/' dat.subj '/' strrep(dat.fileName,'mat','pdf')]);
    end
    
    cleanup(0,dat);
    
    %draw_response_screen(w,dat,0);
    
catch
    
    cleanup(0,dat);
    psychrethrow(psychlasterror);
    
end
