function test(dat)
%
% nback performance for pre- and post- tests or
% introduction for a given dataset (dat)
%
%
% if dat is empty, you will be prompted to select one or more files with
% the file browser

% manually select files, can combine multiple
if isempty(dat)
    
    [files,path] = uigetfile('../data/*.mat','Select sessions to analyze','multiselect','on');
    
    % initialize fields needed for plotting
    dat.nbacks          = [];
    dat.trials.nback    = [];
    dat.trials.resp         = [];
    dat.trials.respTime     = [];
    dat.trials.isCorrect    = [];
    
    % load these fields from each selected file
    if ~iscell(files)
        
        % just one file to be loaded
        load([path '/' files])
        
    else
        
        % load each file
        for fii = 1:length(files)
            
            display(files(fii));
            tmp = load([path '/' files{fii}]);
            
            dat.nbacks              = [dat.nbacks tmp.dat.nbacks];
            dat.trials.resp         = [dat.trials.resp tmp.dat.trials.resp];
            dat.trials.respTime         = [dat.trials.respTime tmp.dat.trials.respTime];
            dat.trials.isCorrect    = [dat.trials.isCorrect tmp.dat.trials.isCorrect];
        end
        
        % unique stimulus types?
        dat.nbacks = unique(dat.nbacks);
        
        % just takes the test type from the last loaded file, you assumes that
        % you did not accidently select two different test types (e.g., a pre
        % and a post)
        dat.test_type = tmp.dat.test_type;
        
    end
    
end

%calculate percentage of
missed_trials = 100*sum(dat.trials.resp == -1)/sum(~isnan((dat.trials.resp)));

figure; hold on;
suptitle([ dat.test_type ' (perc missed = ' num2str(missed_trials,2) ')']);
set(gcf,'color',[1 1 1]);

%for each nback
for b = 1:length(dat.nbacks)
    
    nback(b) = dat.nbacks(b);
    
    % trials with this nback
    trial_inds = dat.trials.nback == nback(b) & ~isnan(dat.trials.resp);
    
    % performance
    percent_correct(b)    = 100*sum(dat.trials.isCorrect(trial_inds) == 1)/sum(trial_inds);
    
    %% XXX I think we should divide by the num of signal and num of noise trials, not the sum of all trials??? XXX
    
    signal_trial_inds = dat.trials.nBackTrue(trial_inds) == 1;
    noise_trial_inds  = dat.trials.nBackTrue(trial_inds) == 0;
    
    hits(b)               = sum(dat.trials.resp(trial_inds) == 1 & signal_trial_inds)/sum(signal_trial_inds);
    false_alarms(b)       = sum(dat.trials.resp(trial_inds) == 1 & noise_trial_inds)/sum(noise_trial_inds);
    
    %hits(b)               = sum(dat.trials.resp(trial_inds) == 1 & dat.trials.nBackTrue(trial_inds) == 1)/sum(trial_inds);
    %false_alarms(b)       = sum(dat.trials.resp(trial_inds) == 1 & dat.trials.nBackTrue(trial_inds) == 0)/sum(trial_inds);
    
    median_rt(b)          = nanmedian(dat.trials.respTime(trial_inds));          
    
    % d prime - calculated on each motion direction
    if numel(trial_inds) > 1
        [dp(b),beta(b)] = dprime(hits(b),false_alarms(b),sum(signal_trial_inds));
    else
        dp(b) = NaN;
    end
    
end
    
    csvwrite('0067D.csv', [hits(1), 1-hits(1), false_alarms(1), ...
    1-false_alarms(1), dp(1), hits(2), 1-hits(2), false_alarms(2), ...
    1-false_alarms(2), dp(2)]) 