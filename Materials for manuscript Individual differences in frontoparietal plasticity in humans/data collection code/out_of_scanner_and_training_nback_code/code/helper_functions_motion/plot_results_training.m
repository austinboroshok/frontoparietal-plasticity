function plot_results_training(dat,window_size)
%
% plots percent correct on letter recall task for a given dataset (dat), averaged over a number of
% trials indicated by window_size
%
% if dat is empty, you will be prompted to select one or more files with
% the file browser

% manually select files, can combine multiple
if isempty(dat)
    
    [files,path] = uigetfile('../data/*.mat','Select sessions to analyze','multiselect','on');
    
    % initialize fields needed for plotting
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
            
            dat.trials.isCorrect    = [dat.trials.isCorrect tmp.dat.trials.isCorrect(~isnan(tmp.dat.trials.isCorrect))];
            
        end
        
    end
    
end

figure; hold on; 
set(gcf,'color',[1 1 1]);

% overall percent correct
percent_correct_all = 100*sum(dat.trials.isCorrect)/length(dat.trials.isCorrect);
suptitle(['Overall Percent Correct:' num2str(percent_correct_all,3)]);

subplot(1,2,1); hold on;
plot(1:length(dat.trials.isCorrect),dat.trials.isCorrect,'ko-','markerfacecolor',ColorIt('o'));
ylabel('was correct');
xlabel('time (trials)');
box on;

if length(dat.trials.isCorrect)-window_size-1 >= 1
    
    % sliding window percent correct
    for tr = 1:length(dat.trials.isCorrect)-window_size-1
        
        percent_correct(tr) = 100*sum(dat.trials.isCorrect(tr:tr+window_size-1))/window_size;
        
    end
    
    subplot(1,2,2); hold on;
    plot(1:length(dat.trials.isCorrect)-window_size-1,percent_correct,'ko-','markerfacecolor',ColorIt('o'));
    
end

subplot(1,2,2); hold on;
ylabel('percent correct (window average)');
xlabel('time (trials)');
box on;