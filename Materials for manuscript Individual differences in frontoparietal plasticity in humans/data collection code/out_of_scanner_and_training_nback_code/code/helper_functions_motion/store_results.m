function store_results(dat)
%
% store stimulus info, behavioral and eyetracking data

% make directory to store session data
if ~exist(['../data/' dat.subj],'dir');
    mkdir(['../data/' dat.subj]);
end

save(['../data/' dat.subj '/' dat.fileName],'dat');
