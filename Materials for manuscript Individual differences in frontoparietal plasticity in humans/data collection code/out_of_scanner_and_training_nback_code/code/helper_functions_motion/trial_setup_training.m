function [dat] = trial_setup_training(dat)
%
% define features of trial structure

%  TRIAL STRUCTURE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dat.letter_set = char('A':'Z');

dat.trials.trialnum         = [];

for r = 1:dat.repeats
    
    % letters
    dat.trials.letterInds(r,:) = randi(26,10,1);
    dat.trials.whiteInds(r,:)  = [randi([1 5],1) randi([6 10],1)];
    
    % set up letter colors
    dat.trials.letterColors(r,:) = zeros(10,1);
    dat.trials.letterColors(r,dat.trials.whiteInds(r,:)) = 1;
    
end

% emptry response arrays
dat.trials.trialnum     = 1:dat.repeats;
dat.trials.resp         = cell(1,dat.repeats);
dat.trials.respCode     = NaN*ones(dat.repeats,2);
dat.trials.isCorrect    = NaN*ones(1,dat.repeats);

% timing
dat.letter_sec   = 0.500; % length of letter presentation in seconds
dat.interval_sec = 0.1167; % inter-letter interval

dat.trial_sec = dat.letter_sec + dat.interval_sec;