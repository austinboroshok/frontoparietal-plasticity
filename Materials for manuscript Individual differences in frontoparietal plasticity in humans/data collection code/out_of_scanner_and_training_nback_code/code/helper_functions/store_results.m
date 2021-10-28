function store_results(dat)
%
% store stimulus info, behavioral and eyetracking data

save(['../data/' dat.subj '/' dat.fileName],'dat');
