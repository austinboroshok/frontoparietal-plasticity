function [dat,allsounds] = stimulus_setup(dat)
%
% get file info for sounds

dat.sound_dir   = ['../Sounds/' dat.sound_set];

%sound_file_directory is a variable linking to directory Sounds
sound_files = dir([dat.sound_dir '/*.wav']);

% make dir for wavs case insensitive due to weirdness with Mac/PC file naming
%sound_files = [dir([dat.sound_dir '/*.wav']); dir([dat.sound_dir '/*.WAV'])];

for k = 1:length(sound_files)
    
    % file name
    dat.sound_file_names{k} = [dat.sound_dir '/' sound_files(k).name];
    
    % preload sounds
    [allsounds(k).y, allsounds(k).Fs]     = audioread(dat.sound_file_names{k});
    
end

dat.num_syls  = k;