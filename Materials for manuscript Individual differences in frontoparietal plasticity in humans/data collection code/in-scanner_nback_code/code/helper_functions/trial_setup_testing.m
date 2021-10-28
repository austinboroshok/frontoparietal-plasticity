function [dat] = trial_setup_testing(dat)
%
% define features of trial structure


%  TRIAL STRUCTURE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in text file with sequences
fid = fopen(['../experiments/' dat.experiment_file ]);
tline = fgetl(fid);
cnt = 1;
while ischar(tline)
    dat.sequence_files{cnt} = [tline '_' dat.test_type '.txt'];
    tline = fgetl(fid);
    cnt = cnt + 1;
end
fclose(fid);

dat.trials.sound_file = [];
dat.trials.sound_index = [];
dat.trials.nback        = [];
dat.trials.block        = [];

cnt = 1;

% for each sequence file
for c = 1:length(dat.sequence_files)
    
    % get nback number from this sequence
    nback = str2num(dat.sequence_files{c}(6));
    
    % read in sound sequence
    fid = fopen(['../setlists/' dat.sound_set '/' dat.sequence_files{c} ]);
    tline = fgetl(fid);
    while ischar(tline)
        
        % store trial info
        dat.trials.sound_file{cnt} = ['../Sounds/' dat.sound_set '/' tline];
        dat.trials.sound_index(cnt) = find(strcmp([lower(dat.sound_file_names)], lower(dat.trials.sound_file{cnt})));
        dat.trials.nback(cnt)      = nback;
        dat.trials.block(cnt)      = c;
        
        % get next line
        tline = fgetl(fid);
        cnt = cnt + 1;
    end
    fclose(fid);
    

end

dat.nbacks = unique(dat.trials.nback);

% emptry response arrays
dat.trials.resp         = NaN*ones(1,numel(dat.trials.nback));
dat.trials.respTime     = NaN*ones(1,numel(dat.trials.nback));
dat.trials.isCorrect    = NaN*ones(1,numel(dat.trials.nback));
dat.trials.nBackTrue    = NaN*ones(1,numel(dat.trials.nback));

