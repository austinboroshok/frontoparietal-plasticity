function dat = correct_key_responses(dat)
%
% original code did not fill in the nbacktrue field properly and used -1
% and NaN redundantly, so we reprocesses responses so that each trial
% contains nbacktrue info and nonresponses are always coded as NaN

% RECOMPUTE ISCORRECT AND NBACK TRUE, DEALING WITH INITIAL TRIALS IN EACH
% BLOCK AND NON REPONSES

dat.trials.isCorrect = nan(size(dat.trials.isCorrect));
dat.trials.nBackTrue = nan(size(dat.trials.nBackTrue));

% store trial number WITHIN BLOCK
currentBlock = 0;
blockTrial   = 0;

for trial = 1:length(dat.trials.resp)
    
    current_nback = dat.trials.nback(trial);
    
    response = dat.trials.resp(trial);
    
    sound_index = dat.trials.sound_index(trial); 
    
    
    % role over to a new block
    if dat.trials.block(trial) > currentBlock
        blockTrial = 1;
        currentBlock = currentBlock + 1;
    end
    
    % if the trial number is greater than the nback number
    if blockTrial > current_nback
        
        if response == 1 && sound_index == dat.trials.sound_index(trial-current_nback)
            
            dat.trials.isCorrect(trial) = 1;
            dat.trials.nBackTrue(trial) = 1;
            
        elseif response == 2 && ~(sound_index == dat.trials.sound_index(trial-current_nback))
            
            dat.trials.isCorrect(trial) = 1;
            dat.trials.nBackTrue(trial) = 0;
            
        elseif response == 1 && ~(sound_index == dat.trials.sound_index(trial-current_nback))
            
            dat.trials.isCorrect(trial) = 0;
            dat.trials.nBackTrue(trial) = 0;
            
        elseif response == 2 && sound_index == dat.trials.sound_index(trial-current_nback)
            
            dat.trials.isCorrect(trial) = 0;
            dat.trials.nBackTrue(trial) = 1;
            
        elseif response == -1 && sound_index == dat.trials.sound_index(trial-current_nback)
            
            dat.trials.isCorrect(trial) = NaN;
            dat.trials.nBackTrue(trial) = 1;
            dat.trials.resp(trial) = NaN;
            
        elseif response == -1 && ~(sound_index == dat.trials.sound_index(trial-current_nback))
            
            dat.trials.isCorrect(trial) = NaN;
            dat.trials.nBackTrue(trial) = 0;
            dat.trials.resp(trial) = NaN;
        
        end
        
    elseif blockTrial <= current_nback
        
        % first trials, correct answer is always no
        if response == 1
            
            dat.trials.isCorrect(trial) = 0;
            dat.trials.nBackTrue(trial) = 0;
            
        elseif response == 2
            
            dat.trials.isCorrect(trial) = 1;
            dat.trials.nBackTrue(trial) = 0;
            
        elseif response == -1
            
            dat.trials.isCorrect(trial) = NaN;
            dat.trials.nBackTrue(trial) = 0;
            dat.trials.resp(trial) = NaN;
            
        end
        
    end
    
    blockTrial = blockTrial + 1;
    
end