function [dat] = trial_setup_introduction(dat)
%
% define features of trial structure

% TIMING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dat.trial_sec = 0.5;

%  TRIAL STRUCTURE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dat.block = 1;

dat.trials.coherence        = [];
dat.trials.direction        = [];
dat.trials.repeat           = [];
dat.trials.block            = [];
dat.trials.trialnum         = [];


tr_cnt = 1;

for c = 1:length(dat.coherences)
    
    start_trial = tr_cnt;
    
    for n = 1:length(dat.directions)
        
        for r = 1:dat.repeats(c)
            
            % block number
            dat.trials.block    = [dat.trials.block c];
            
            % signal trials
            dat.trials.coherence    = [dat.trials.coherence dat.coherences(c)];
            dat.trials.direction    = [dat.trials.direction dat.directions(n)];
            dat.trials.repeat       = [dat.trials.repeat r];
            
            tr_cnt = tr_cnt + 1;
            
        end
    end
    
    end_trial = tr_cnt - 1;
    
    % randomize trial order within a block
    dat.trials.trialnum = [dat.trials.trialnum Shuffle(start_trial:end_trial)];

end

% emptry response arrays
dat.trials.resp         = NaN*ones(1,length(dat.trials.coherence));
dat.trials.isCorrect    = NaN*ones(1,length(dat.trials.coherence));


