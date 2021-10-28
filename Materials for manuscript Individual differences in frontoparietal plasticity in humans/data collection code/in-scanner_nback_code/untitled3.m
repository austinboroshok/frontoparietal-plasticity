
        
        % unique stimulus types?
        dat.nbacks = unique(dat.nbacks);
       
 missed_trials = 100*sum(dat.trials.resp == -1)/sum(~isnan((dat.trials.resp)));
 
        
        
for b = 1:length(dat.nbacks)
    
    nback(b) = dat.nbacks(b);
    
    % trials with this nback
    trial_inds = dat.trials.nback == nback(b) & ~isnan(dat.trials.resp);
    
    % performance
    percent_correct(b)    = 100*sum(dat.trials.isCorrect(trial_inds) == 1)/sum(trial_inds);
    
    %% XXX I think we should divide by the num of signal and num of noise trials, not the sum of all trials??? XXX
    
    signal_trial_inds = dat.trials.nBackTrue(trial_inds) == 1;
    noise_trial_inds  = dat.trials.nBackTrue(trial_inds) == 0;
    
    hits(b)               = sum(dat.trials.resp(trial_inds) == 1 & signal_trial_inds)/sum(signal_trial_inds);
    false_alarms(b)       = sum(dat.trials.resp(trial_inds) == 1 & noise_trial_inds)/sum(noise_trial_inds);
    
    %hits(b)               = sum(dat.trials.resp(trial_inds) == 1 & dat.trials.nBackTrue(trial_inds) == 1)/sum(trial_inds);
    %false_alarms(b)       = sum(dat.trials.resp(trial_inds) == 1 & dat.trials.nBackTrue(trial_inds) == 0)/sum(trial_inds);
    
    median_rt(b)          = nanmedian(dat.trials.respTime(trial_inds));          
    
    % d prime - calculated on each motion direction
    if numel(trial_inds) > 1
        [dp(b),beta(b)] = dprime(hits(b),false_alarms(b),sum(signal_trial_inds));
    else
        dp(b) = NaN;
    end
end
