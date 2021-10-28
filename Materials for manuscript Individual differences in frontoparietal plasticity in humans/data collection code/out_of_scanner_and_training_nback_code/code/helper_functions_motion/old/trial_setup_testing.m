function [dat] = trial_setup_testing(dat)
%
% define features of trial structure

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
            dat.trials.block    = [dat.trials.block c c];
            
            % signal trials
            dat.trials.coherence    = [dat.trials.coherence dat.coherences(c)];
            dat.trials.direction    = [dat.trials.direction dat.directions(n)];
            dat.trials.repeat       = [dat.trials.repeat r];
            
            % noise trials
            dat.trials.coherence    = [dat.trials.coherence 0];
            dat.trials.direction    = [dat.trials.direction dat.directions(n)];
            dat.trials.repeat       = [dat.trials.repeat r];
            
            tr_cnt = tr_cnt + 2;
            
        end
    end
    
    end_trial = tr_cnt - 1;
    
    % randomize trial order within a block
    dat.trials.trialnum = [dat.trials.trialnum Shuffle(start_trial:end_trial)];

end

% emptry response arrays
dat.trials.resp         = cell(1,length(dat.trials.coherence));
dat.trials.respCode     = NaN*ones(1,length(dat.trials.coherence));
dat.trials.isCorrect    = NaN*ones(1,length(dat.trials.coherence));


