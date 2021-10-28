function [omitted_trials,percent_correct,hits,false_alarms,misses,crs,dp,median_rt] = sub_compute_nback_performance(dat);
%
%

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
            
        elseif response == -1 && ~(sound_index == dat.trials.sound_index(trial-current_nback))
            
            dat.trials.isCorrect(trial) = NaN;
            dat.trials.nBackTrue(trial) = 0;
        
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
            
        end
        
    end
    
    blockTrial = blockTrial + 1;
    
end


%for each nback
for b = 1:length(dat.nbacks)
    
    nback(b) = dat.nbacks(b);
    
    % trials with this nback
    trial_inds = dat.trials.nback == nback(b);
    
    %calculate proportion of missed trials
    omitted_trial_inds = dat.trials.resp == -1;
    omitted_trials(b) = sum(omitted_trial_inds & trial_inds)/sum(trial_inds);
    
    % indices of valid trials for this nback
    valid_trial_inds = trial_inds & ~omitted_trial_inds;
    
    % percent correct of trials with a valid response
    percent_correct(b)  = sum(dat.trials.isCorrect(valid_trial_inds) == 1)/sum(valid_trial_inds);
    
    % get indices of signal and noise trials
    signal_trial_inds = dat.trials.nBackTrue == 1;
    noise_trial_inds = dat.trials.nBackTrue  == 0;

    % hits and fa's are calculated for signal and noise trials for this nback, with missed key presses excluded
    hits(b)         = sum(dat.trials.isCorrect(valid_trial_inds & signal_trial_inds))/sum(valid_trial_inds & signal_trial_inds);
    false_alarms(b) = sum(~dat.trials.isCorrect(valid_trial_inds & noise_trial_inds))/sum(valid_trial_inds & noise_trial_inds);
    
    % misses and correct rejections
    misses(b)   = sum(~dat.trials.isCorrect(valid_trial_inds & signal_trial_inds))/sum(valid_trial_inds & signal_trial_inds);
    crs(b)      = sum(dat.trials.isCorrect(valid_trial_inds & noise_trial_inds))/sum(valid_trial_inds & noise_trial_inds);
    
    % median of reaction time in seconds
    median_rt(b)          = median(dat.trials.respTime(valid_trial_inds));
    
    % precompute max and min possible for hits and false alarms
    dp_maxval = (sum(signal_trial_inds)-0.5)/sum(signal_trial_inds);
    dp_minval = 0.5/sum(signal_trial_inds);
    
    fa_maxval = (sum(noise_trial_inds)-0.5)/sum(noise_trial_inds);
    fa_minval = 0.5/sum(noise_trial_inds);
    
    % correct hits and fas for dprime calculation so that there are no 1's
    % or 0's, also convert to proportions
    if hits(b) == 1
        hits_dp = dp_maxval;
    elseif hits(b) == 0
        hits_dp = dp_minval;
    else
        hits_dp = hits(b);
    end
    
    if false_alarms(b) == 1
        false_alarms_dp = fa_maxval;
    elseif false_alarms(b) == 0
        false_alarms_dp = fa_minval;
    else
        false_alarms_dp = false_alarms(b);
    end
    
    
    %-- Convert to Z scores
    zHit = norminv(hits_dp);
    zFA  = norminv(false_alarms_dp);
    
    %-- Calculate d-prime
    dp(b) = zHit - zFA ;
    
    % calculate criterion (positive = yes bias)
    %crit(b) = (zHit + zFA)/2;
    
end