[files,path] = uigetfile('../data/*.mat','Select PRETEST file(s)','multiselect','on');
pre_file_split = strsplit(files, '_'); pre_subid = pre_file_split(1); 
pre = load_and_combine_files(files,path,'pretest');

% manually select files posttest files, can combine multiple
[files,path] = uigetfile('../data/*.mat','Select POSTTEST files(s)','multiselect','on');
post_file_split = strsplit(files, '_'); post_subid = post_file_split(1); 
post = load_and_combine_files(files,path,'posttest');

if strcmp(pre_subid, post_subid) == 0
    error("pre subject ID and post subject ID do not match")
end

subid = pre_subid;

%get calculation of missed trials
pre_missed_trials = ((100*sum(pre.trials.resp == -1))/sum(~isnan((pre.trials.resp))));
post_missed_trials = ((100*sum(post.trials.resp == -1))/sum(~isnan((post.trials.resp))));
missed_trials = (((pre_missed_trials)+(post_missed_trials))/(2));


figure; hold on;
suptitle([ ' (perc missed = ' num2str(missed_trials,2) ')']);

set(gcf,'color',[1 1 1]);
set(gcf,'Units','pixels','Position',[0 0 1000 600]);

for b = 1:length(pre.nbacks)
    
    nback(b) = pre.nbacks(b);
    
    % trials with this nback
    pre_trial_inds = pre.trials.nback == nback(b) & ~isnan(pre.trials.resp);
    post_trial_inds = post.trials.nback == nback(b) & ~isnan(post.trials.resp);

    % performance
    pre_percent_correct(b)    = 100*sum(pre.trials.isCorrect(pre_trial_inds) == 1)/sum(pre_trial_inds);
    post_percent_correct(b)   = 100*sum(post.trials.isCorrect(post_trial_inds) == 1)/sum(post_trial_inds);

    pre_signal_trial_inds = pre.trials.nBackTrue(pre_trial_inds) == 1;
    post_signal_trial_inds = post.trials.nBackTrue(post_trial_inds) == 1;

    pre_noise_trial_inds  = pre.trials.nBackTrue(pre_trial_inds) == 0;
    post_noise_trial_inds  = post.trials.nBackTrue(post_trial_inds) == 0;


    pre_hits(b)               = sum(pre.trials.resp(pre_trial_inds) == 1 & pre_signal_trial_inds)/sum(pre_signal_trial_inds);
    post_hits(b)              = sum(post.trials.resp(post_trial_inds) == 1 & post_signal_trial_inds)/sum(post_signal_trial_inds);
    

    pre_false_alarms(b)       = sum(pre.trials.resp(pre_trial_inds) == 1 & pre_noise_trial_inds)/sum(pre_noise_trial_inds);
    post_false_alarms(b)      = sum(post.trials.resp(post_trial_inds) == 1 & post_noise_trial_inds)/sum(post_noise_trial_inds);
    

    pre_median_rt(b)          = median(pre.trials.respTime(pre_trial_inds));          
    post_median_rt(b)         = median(post.trials.respTime(post_trial_inds));
    % d prime - calculated on each nback dprime(hits(b),false_alarms(b),sum(trial_inds));
    if numel(pre_trial_inds) > 1
        [pre_dp(b)] = dprime(pre_hits(b),pre_false_alarms(b),sum(pre_signal_trial_inds));

        [post_dp(b)] = dprime(post_hits(b),post_false_alarms(b),sum(post_signal_trial_inds));
    else
        pre_dp(b) = NaN;
        post_dp(b)= NaN;

    end
end

subplot(2,2,1); hold on;
plot(nback, pre_percent_correct, 'r-o', nback, post_percent_correct, 'g-o');
title('N-BACK Percentage Correct');
xlabel('nback');
ylabel('Percentage Correct');
ylim([0 100]);
legend('pretest', 'posttest','Location', 'southwestoutside');
box on;


subplot(2,2,2); hold on;
plot(nback, pre_dp, 'r-o', nback, post_dp, 'g-o');
title('N-Back Sensitivity')
xlabel('nback');
ylabel('Sensitivity');
legend('pretest', 'posttest','Location', 'southwestoutside');
box on;

% subplot(2,2,3); hold on;
% plot(nback, pre_median_rt, 'r', nback, post_median_rt, 'g');
% title('N-Back Median RT');
% xlabel('nback');
% ylabel('RT');
% xlim([2 4]);
% legend('pretest', 'posttest','Location', 'southwestoutside');
% box on; 

%% Write output csv file

headers = {'pre_2_hit','pre_2_miss','pre_2_fa','pre_2_cr','pre_2_dp', ... 
    'pre_3_hit', 'pre_3_miss','pre_3_fa','pre_3_cr','pre_3_dp', ...
    'pre_4_hit','pre_4_miss','pre_4_fa','pre_4_cr','pre_4_dp', ...
    'post_2_hit','post_2_miss','post_2_fa','post_2_cr','post_2_dp', ...
    'post_3_hit','post_3_miss','post_3_fa','post_3_cr','post_3_dp', ...
    'post_4_hit','post_4_miss','post_4_fa','post_4_cr','post_4_dp'};

data = ([pre_hits(1), 1-pre_hits(1), pre_false_alarms(1), 1-pre_false_alarms(1), pre_dp(1), ...
    pre_hits(2), 1-pre_hits(2), pre_false_alarms(2), 1-pre_false_alarms(2), pre_dp(2), ...
    pre_hits(3), 1-pre_hits(3), pre_false_alarms(3), 1-pre_false_alarms(3), pre_dp(3)...
    post_hits(1), 1-post_hits(1), post_false_alarms(1), 1-post_false_alarms(1), post_dp(1), ...
    post_hits(2), 1-post_hits(2), post_false_alarms(2), 1-post_false_alarms(2), post_dp(2), ...
    post_hits(3), 1-post_hits(3), post_false_alarms(3), 1-post_false_alarms(3), post_dp(3)]);

csvwrite_with_headers(strcat(char(subid),'.csv'),data,headers);