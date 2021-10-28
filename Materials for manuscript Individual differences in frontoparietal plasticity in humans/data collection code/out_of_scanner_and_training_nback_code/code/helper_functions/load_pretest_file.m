function dat = load_pretest_file(subj)
%
% load a pretest file to determine stimulus parameters 

listing = dir([ '../data/' subj '/' subj '_pretest_*.mat']);

if strcmp(subj,'junk')
    
    if length(listing) == 1
        load(['../data/' subj '/' listing.name]);
    elseif isempty(listing)
        error('no pretest for this participant.');
    elseif length(listing) > 1
        load(['../data/' subj '/' listing(end).name]);
    end
    
else
     
    if length(listing) == 1
        load(['../data/' subj '/' listing.name]);
    elseif isempty(listing)
        error('no pretest for this participant.');
    else
        error('more than 1 pretest with this name, delete duplicate tests');
    end
    
end