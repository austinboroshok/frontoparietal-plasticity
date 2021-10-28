function [dat] = trial_setup_training(dat)
%
% define features of trial structure


%  TRIAL STRUCTURE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dat.trials.nback        = [];
dat.trials.block        = [];
dat.trials.sound_file   = {};
dat.trials.sound_index  = [];
dat.trials.targets      = [];

% for each nback
for c = 1:dat.nbacks
    
    % fill in block number
    dat.trials.block = [dat.trials.block repmat(c,1,dat.repeats)];
    
    % only store nback value and letter sequence if this is the first block
    if c == 1
        dat.trials.nback    = [dat.trials.nback repmat(dat.first_nback,1,dat.repeats)];
        
        % generate list of syllables with 3 or 4 targets
        [sound_indices, targets] = generate_nback(dat.first_nback,dat.repeats,dat.num_syls);
        
        dat.trials.sound_index      = [dat.trials.sound_index sound_indices];
        dat.trials.sound_file       = [dat.trials.sound_file {dat.sound_file_names{sound_indices}}];
        dat.trials.targets          = [dat.trials.targets targets];
    end
    
end

% emptry response arrays
dat.trials.resp         = NaN*ones(1,numel(dat.trials.block));
dat.trials.respTime     = NaN*ones(1,numel(dat.trials.block));
dat.trials.isCorrect    = NaN*ones(1,numel(dat.trials.block));
dat.trials.nBackTrue    = NaN*ones(1,numel(dat.trials.block));


