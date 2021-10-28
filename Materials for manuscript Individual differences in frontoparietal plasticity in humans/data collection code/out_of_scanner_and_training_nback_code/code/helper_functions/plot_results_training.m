function plot_results_training(dat)
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
    dat.trials.resp     = [];
    dat.trials.respTime     = [];
    dat.trials.nBackTrue    = [];
    dat.trials.isCorrect    = [];
    dat.trials.sound_index = [];
    dat.trials.sound_file = [];
    dat.trials.block = [];
    
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
            dat.trials.nBackTrue    = [dat.trials.nBackTrue tmp.dat.trials.nBackTrue];
            dat.trials.isCorrect    = [dat.trials.isCorrect tmp.dat.trials.isCorrect];
            
            dat.trials.sound_index    = [dat.trials.sound_index tmp.dat.trials.sound_index];
            dat.trials.sound_file = {dat.trials.sound_file tmp.dat.trials.sound_file};
            
            dat.trials.block = [dat.trials.block tmp.dat.trials.block];
        end
        
        % unique stimulus types?
        dat.nbacks = unique(dat.nbacks);
        
        % just takes the test type from the last loaded file, you assumes that
        % you did not accidently select two different test types (e.g., a pre
        % and a post)
        dat.test_type = tmp.dat.test_type;
        
    end
    
end


% if there are any nans in the nBackTrue field, this was processed with the
% old response code and needs to be re-run before analysis
if any(isnan(dat.trials.nBackTrue))
    
    % correct response handing in mat file
    dat = correct_key_responses(dat);
       
end

% create corrected csv
outputname  = strrep(['../data/' dat.subj '/CORRECTED_' dat.fileName],'mat','csv');
outfile     = fopen(outputname, 'w');

if outfile == -1
    outputname  = strrep(['../data/' dat.subj(4:end) '/CORRECTED_' dat.fileName],'mat','csv');
    outfile     = fopen(outputname, 'w');
end

%fprintf(outfile,'Trial,Block,Nback,Sound,Response,RT_seconds,NBackTrue,isCorrect\r\n');
% for each trial

for trial = 1:length(dat.trials.resp)
    
%    fprintf(outfile, '%d,%d,%d,%s,%d,%d,%d,%d\r\n', trial, dat.trials.block(trial), dat.trials.nback(trial),...
%        strcat(dat.sound_dir,'/', dat.trials.sound_file{trial}),dat.trials.resp(trial), dat.trials.respTime(trial), dat.trials.nBackTrue(trial), dat.trials.isCorrect(trial));
    
end


% how many blocks?
blockNum = length(unique(dat.trials.block));

%for each block
for b = 1:blockNum
    
    % indices for all trials in this block
    trial_inds = dat.trials.block == b;
    
    % what nback for this block
    nback(b) = unique(dat.trials.nback(trial_inds));
    
    %calculate proportion of missed trials
    omitted_trial_inds = isnan(dat.trials.resp);
    omitted_trials(b) = sum(omitted_trial_inds & trial_inds)/sum(trial_inds);
    
    % indices of valid trials for this nback
    valid_trial_inds = trial_inds & ~omitted_trial_inds;
    
    % percent correct of trials with a valid response
    percent_correct(b)  = sum(dat.trials.isCorrect(valid_trial_inds) == 1)/sum(valid_trial_inds);
    
    % get indices of signal and noise trials
    signal_trial_inds = dat.trials.nBackTrue == 1;
    noise_trial_inds = dat.trials.nBackTrue  == 0;
    
    % hits and fa's are calculated for signal and noise trials for this nback, with missed key presses excluded
    hits(b)         = sum(dat.trials.isCorrect(valid_trial_inds & signal_trial_inds))/sum(valid_trial_inds & signal_trial_inds);
    false_alarms(b) = sum(~dat.trials.isCorrect(valid_trial_inds & noise_trial_inds))/sum(valid_trial_inds & noise_trial_inds);
    
    % misses and correct rejections
    misses(b)   = sum(~dat.trials.isCorrect(valid_trial_inds & signal_trial_inds))/sum(valid_trial_inds & signal_trial_inds);
    crs(b)      = sum(dat.trials.isCorrect(valid_trial_inds & noise_trial_inds))/sum(valid_trial_inds & noise_trial_inds);
    
    % median of reaction time in seconds
    median_rt(b)          = median(dat.trials.respTime(valid_trial_inds));
    
    % precompute max and min possible for hits and false alarms
    dp_maxval = (sum(signal_trial_inds)-0.5)/sum(signal_trial_inds);
    dp_minval = 0.5/sum(signal_trial_inds);
    
    fa_maxval = (sum(noise_trial_inds)-0.5)/sum(noise_trial_inds);
    fa_minval = 0.5/sum(noise_trial_inds);
    
    % correct hits and fas for dprime calculation so that there are no 1's
    % or 0's, also convert to proportions
    if hits(b) == 1
        hits_dp = dp_maxval;
    elseif hits(b) == 0
        hits_dp = dp_minval;
    else
        hits_dp = hits(b);
    end
    
    if false_alarms(b) == 1
        false_alarms_dp = fa_maxval;
    elseif false_alarms(b) == 0
        false_alarms_dp = fa_minval;
    else
        false_alarms_dp = false_alarms(b);
    end
    
    
    %-- Convert to Z scores
    zHit = norminv(hits_dp);
    zFA  = norminv(false_alarms_dp);
    
    %-- Calculate d-prime
    dp(b) = zHit - zFA ;
    
    
end


% print results to the command prompt
T = table;
T.nback = nback';
T.omitted_trials = omitted_trials';
T.percent_correct = percent_correct';
T.hits = hits';
T.false_alarms = false_alarms';
T.misses = misses';
T.cor_rejs = crs';
T.dprime = dp';
T.reaction_time = median_rt';


% print
T

% average trials omitted in 2, 3, and 4 back
omitted_average = sum(omitted_trials)/blockNum;

figure; hold on;
suptitle([ dat.test_type ' (perc missed = ' num2str(100*omitted_average,2) ')']);
set(gcf,'color',[1 1 1]);


subplot(2,2,1); hold on;
plot(nback,100*percent_correct,'o','color',ColorIt(2),'markerfacecolor',ColorIt(2));
ylabel('percent correct');
xlabel('nback');
ylim([0 100]);
box on;


subplot(2,2,2); hold on;
h(1) = plot(nback,hits,'o','color',ColorIt(1),'markerfacecolor',ColorIt(1));
h(2) = plot(nback,false_alarms,'o','color',ColorIt(3),'markerfacecolor',ColorIt(3));
legend(h,'hits','false alarms');
ylabel('percent');
xlabel('nback');
%ylim([0 5]);
box on;

subplot(2,2,3); hold on;
plot(nback,median_rt,'o','color',ColorIt(2),'markerfacecolor',ColorIt(2));
ylabel('median RT seconds');
xlabel('nback')
box on;

subplot(2,2,4); hold on;
plot(nback,dp,'o','color',ColorIt(2),'markerfacecolor',ColorIt(2));
ylabel('dprime');
xlabel('nback')
box on;


figure; hold on;
suptitle([ dat.test_type ' (perc missed = ' num2str(100*omitted_average,2) ')']);
set(gcf,'color',[1 1 1]);


subplot(2,2,1); hold on;
plot(1:blockNum,100*percent_correct,'o-','color',ColorIt(2),'markerfacecolor',ColorIt(2));
ylabel('percent correct');
xlabel('block');
ylim([0 100]);
box on;


subplot(2,2,2); hold on;
h(1) = plot(1:blockNum,hits,'o-','color',ColorIt(1),'markerfacecolor',ColorIt(1));
h(2) = plot(1:blockNum,false_alarms,'o-','color',ColorIt(3),'markerfacecolor',ColorIt(3));
legend(h,'hits','false alarms');
ylabel('percent');
xlabel('block');
%ylim([0 5]);
box on;

subplot(2,2,3); hold on;
plot(1:blockNum,median_rt,'o-','color',ColorIt(2),'markerfacecolor',ColorIt(2));
ylabel('median RT seconds');
xlabel('block')
box on;

subplot(2,2,4); hold on;
plot(1:blockNum,dp,'o-','color',ColorIt(2),'markerfacecolor',ColorIt(2));
ylabel('dprime');
xlabel('block')
box on;

figure; hold on;
suptitle([ dat.test_type ' (perc missed = ' num2str(100*omitted_average,2) ')']);
set(gcf,'color',[1 1 1]);

plotyy(1:blockNum,100*percent_correct,1:blockNum,nback,'plot','stem');
ylabel('percent correct');
xlabel('block');
ylim([0 100]);
box on;


