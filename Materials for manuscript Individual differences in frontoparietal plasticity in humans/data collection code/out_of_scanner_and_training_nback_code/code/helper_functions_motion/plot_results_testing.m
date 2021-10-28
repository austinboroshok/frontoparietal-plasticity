function plot_results_testing(dat,showTraining)
%
% plot motion detection performance for pre- and post- tests or
% introduction for a given dataset (dat)
%
% if showTraining == 1, then the randomly selecting training direction will
% be written at the top of the plot. this is set to zero in
% run_porepost_test so that the experimentor can check data quality without
% being exposed to what the training direction is
%
% if dat is empty, you will be prompted to select one or more files with
% the file browser

% manually select files, can combine multiple
if isempty(dat)
    
    [files,path] = uigetfile('../data/*.mat','Select sessions to analyze','multiselect','on');
    
    % initialize fields needed for plotting
    dat.coherences          = [];
    dat.directions          = [];
    dat.trials.coherence    = [];
    dat.trials.direction    = [];
    dat.trials.resp         = [];
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
            
            dat.coherences          = [dat.coherences tmp.dat.coherences];
            dat.directions          = [dat.directions tmp.dat.directions];
            dat.trials.coherence    = [dat.trials.coherence tmp.dat.trials.coherence];
            dat.trials.direction    = [dat.trials.direction tmp.dat.trials.direction];
            dat.trials.resp         = [dat.trials.resp tmp.dat.trials.resp];
            dat.trials.isCorrect    = [dat.trials.isCorrect tmp.dat.trials.isCorrect];
        end
        
        % unique stimulus types?
        dat.coherences = unique(dat.coherences);
        dat.directions = unique(dat.directions);
        
        % just takes the test type from the last loaded file, you assumes that
        % you did not accidently select two different test types (e.g., a pre
        % and a post)
        dat.test_type = tmp.dat.test_type;
        dat.main_dirction = tmp.dat.main_direction;
        
    end
    
end

figure; hold on;

% if requested, the training direction is listed in the title
if(showTraining)
    suptitle([dat.test_type ' training on ' num2str(dat.main_direction)]);
else
    suptitle(dat.test_type);
end

set(gcf,'color',[1 1 1]);

%for each coherence
for b = 1:length(dat.coherences)
    
    % for each motion direction
    for d = 1:length(dat.directions)
        
        coherence(b,d) = dat.coherences(b);
        direction(b,d) = dat.directions(d);
        
        % trials with this coherence and this direction
        trial_inds = dat.trials.coherence == coherence(b,d) & dat.trials.direction == direction(b,d) & ~isnan(dat.trials.resp);
        
        % trials with this coherence and NOT this direction
        noise_inds = dat.trials.coherence == coherence(b,d) & dat.trials.direction ~= direction(b,d) & ~isnan(dat.trials.resp);
        
        % performance
        percent_correct(b,d)    = 100*sum(dat.trials.isCorrect(trial_inds))/sum(trial_inds);
        false_alarms(b,d)       = 100*sum(dat.trials.resp == direction(b,d) & noise_inds)/sum(noise_inds);
        
        % d prime - calculated on each motion direction
        if numel(trial_inds) > 1 && numel(noise_inds) > 1
            [dp(b,d),beta(b,d)] = dprime(percent_correct(b,d)/100,false_alarms(b,d)/100,sum(trial_inds)); 
        else
            dp(b,d) = NaN;
        end
        
    end
    
    subplot(1,2,1); hold on;
    h(b) = plot(direction(b,:),percent_correct(b,:),'o-','color',ColorIt(b),'markerfacecolor',ColorIt(b));
    
    subplot(1,2,2); hold on;
    plot(direction(b,:),dp(b,:),'o-','color',ColorIt(b),'markerfacecolor',ColorIt(b));
    
end

% average all coherences
for d = 1:length(dat.directions)
    
    trial_inds = dat.trials.direction == dat.directions(d) & ~isnan(dat.trials.resp);
    noise_inds = dat.trials.direction ~= dat.directions(d) & ~isnan(dat.trials.resp);
    
    percent_correct_all(d)    = 100*sum(dat.trials.isCorrect(trial_inds))/sum(trial_inds);
    false_alarms_all(d)       = 100*sum(dat.trials.resp == dat.directions(d) & noise_inds)/sum(noise_inds);
    
    % d prime
    if numel(trial_inds) > 1 && numel(noise_inds) > 1
        [dp_all(d),beta_all(d)] = dprime(percent_correct_all(d)/100,false_alarms_all(d)/100,sum(trial_inds));
    else
        dp(b,d) = NaN;
    end
    
end

subplot(1,2,1); hold on;
plot(dat.directions,percent_correct_all,'o-','color',ColorIt('k'),'markerfacecolor',ColorIt('k'),'linewidth',2);

subplot(1,2,2); hold on;
plot(dat.directions,dp_all,'o-','color',ColorIt('k'),'markerfacecolor',ColorIt('k'),'linewidth',2);


% add labels and legend
subplot(1,2,1); hold on;
lh = legend(h,cellstr(num2str(coherence(:,1), '%-d')),'location','southeast');
hlt = text(...
    'Parent', lh.DecorationContainer, ...
    'String', 'coherence', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'Position', [0.5, 1.05, 0], ...
    'Units', 'normalized');
ylabel('percent correct');
xlabel('motion direction');
ylim([0 100]);
box on;

subplot(1,2,2); hold on;
ylabel('sensitivity');
xlabel('motion direction');
ylim([0 5]);
box on;
