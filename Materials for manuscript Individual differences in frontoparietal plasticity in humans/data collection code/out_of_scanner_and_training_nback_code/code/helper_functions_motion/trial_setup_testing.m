function [dat] = trial_setup_testing(dat)
%
% define features of trial structure

% TIMING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dat.trial_sec = 0.5;

%  TRIAL STRUCTURE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dat.trials.coherence        = [];
dat.trials.direction        = [];
dat.trials.repeat           = [];

tr_cnt = 0;

for c = 1:length(dat.coherences)

    for n = 1:length(dat.directions)
        
        for r = 1:dat.repeats(c)
            
            tr_cnt = tr_cnt + 1;
            
            % signal trials
            dat.trials.coherence    = [dat.trials.coherence dat.coherences(c)];
            dat.trials.direction    = [dat.trials.direction dat.directions(n)];
            dat.trials.repeat       = [dat.trials.repeat r];

        end
    end

end

% randomize trial order within a block
dat.trials.trialnum = Shuffle(1:tr_cnt);

% emptry response arrays
dat.trials.resp         = NaN*ones(1,tr_cnt);
dat.trials.isCorrect    = NaN*ones(1,tr_cnt);


