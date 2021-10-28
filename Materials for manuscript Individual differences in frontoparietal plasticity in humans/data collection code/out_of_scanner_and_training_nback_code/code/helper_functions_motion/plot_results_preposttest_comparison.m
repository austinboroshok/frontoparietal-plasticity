function plot_results_preposttest_comparison
%
%

% manually select files pretest files, can combine multiple
[files,path] = uigetfile('../data/*.mat','Select PRETEST file(s)','multiselect','on');

pre = load_and_combine_files(files,path,'pretest');

% manually select files posttest files, can combine multiple
[files,path] = uigetfile('../data/*.mat','Select POSTTEST files(s)','multiselect','on');

post = load_and_combine_files(files,path,'posttest');


figure; hold on;
suptitle(['Training on ' num2str(pre.main_direction) ' (pretest dashed lines, posttest solid lines)']);

set(gcf,'color',[1 1 1]);
set(gcf,'Units','pixels','Position',[0 0 1000 600])

%for each coherence
for b = 1:length(pre.coherences)
    
    % compute overall percent correct at this coherence level
    % pre-test
    pre_trial_inds = pre.trials.coherence == pre.coherences(b) & ~isnan(pre.trials.resp);
    bar_height_coherence(b,1) = 100*sum(pre.trials.isCorrect(pre_trial_inds))/sum(pre_trial_inds);
    
    % post-test
    post_trial_inds = post.trials.coherence == post.coherences(b) & ~isnan(post.trials.resp);
    bar_height_coherence(b,2) = 100*sum(post.trials.isCorrect(post_trial_inds))/sum(post_trial_inds);
    
    % now compute percent correct and dprime separately for each direction
    for d = 1:length(pre.directions)
        
        coherence(b,d) = pre.coherences(b);
        direction(b,d) = pre.directions(d);
        
        %% pre-test trial indices
        pre_trial_inds = pre.trials.coherence == coherence(b,d) & pre.trials.direction == direction(b,d) & ~isnan(pre.trials.resp);
        pre_noise_inds = pre.trials.coherence == coherence(b,d) & pre.trials.direction ~= direction(b,d) & ~isnan(pre.trials.resp);
        
        % percent correct
        pre_percent_correct(b,d) = 100*sum(pre.trials.isCorrect(pre_trial_inds))/sum(pre_trial_inds);
        pre_false_alarms(b,d) = 100*sum(pre.trials.resp == direction(b,d) & pre_noise_inds)/sum(pre_noise_inds);
        
        %% post-test trial indices
        post_trial_inds = post.trials.coherence == coherence(b,d) & post.trials.direction == direction(b,d) & ~isnan(post.trials.resp);
        post_noise_inds = post.trials.coherence == coherence(b,d) & post.trials.direction ~= direction(b,d) & ~isnan(post.trials.resp);
        
        % percent correct
        post_percent_correct(b,d) = 100*sum(post.trials.isCorrect(post_trial_inds))/sum(post_trial_inds);
        post_false_alarms(b,d) = 100*sum(post.trials.resp == direction(b,d) & post_noise_inds)/sum(post_noise_inds);
        
        % dprime
        if numel(pre_trial_inds) > 1 && numel(pre_noise_inds) > 1
            
            [pre_dp(b,d),pre_beta(b,d)] = dprime(pre_percent_correct(b,d)/100,pre_false_alarms(b,d)/100,sum(pre_trial_inds));
            
            [post_dp(b,d),post_beta(b,d)] = dprime(post_percent_correct(b,d)/100,post_false_alarms(b,d)/100,sum(post_trial_inds));
            
        else
            pre_dp(b,d) = NaN;
            post_dp(b,d) = NaN;
        end
        
    end
    
    % average dprime across all directions at this coherence
    bar_height_coherence_dp(b,1) = mean(pre_dp(b,:));
    bar_height_coherence_dp(b,2) = mean(post_dp(b,:));
    
    % line plots
    subplot(2,3,1); hold on;
    plot(direction(b,:),pre_percent_correct(b,:),'o:','color',ColorIt(b),'markerfacecolor',ColorIt(b));
    h(b) = plot(direction(b,:),post_percent_correct(b,:),'o-','color',ColorIt(b),'markerfacecolor',ColorIt(b));
    
    subplot(2,3,4); hold on;
    plot(direction(b,:),pre_dp(b,:),'o:','color',ColorIt(b),'markerfacecolor',ColorIt(b));
    h2(b) = plot(direction(b,:),post_dp(b,:),'o-','color',ColorIt(b),'markerfacecolor',ColorIt(b));
    
    
end

% compute overall percent correct at all coherence levels
% pre-test
bar_height_coherence(b+1,1) = 100*sum(pre.trials.isCorrect(~isnan(pre.trials.resp)))/sum(~isnan(pre.trials.resp));
% post-test
bar_height_coherence(b+1,2) = 100*sum(post.trials.isCorrect(~isnan(post.trials.resp)))/sum(~isnan(post.trials.resp));



% average over all coherences for each direction
for d = 1:length(pre.directions)
    

    % pre
    pre_trial_inds = pre.trials.direction == pre.directions(d) & ~isnan(pre.trials.resp);
    pre_noise_inds = pre.trials.direction ~= pre.directions(d) & ~isnan(pre.trials.resp);
    
    percent_correct(d,1) = 100*sum(pre.trials.isCorrect(pre_trial_inds))/sum(pre_trial_inds);
    false_alarms(d,1) = 100*sum(pre.trials.resp == pre.directions(d) & pre_noise_inds)/sum(pre_noise_inds);
     
    % post
    post_trial_inds = post.trials.direction == pre.directions(d) & ~isnan(post.trials.resp);
    post_noise_inds = post.trials.direction ~= pre.directions(d) & ~isnan(post.trials.resp);
    
    percent_correct(d,2) = 100*sum(post.trials.isCorrect(post_trial_inds))/sum(post_trial_inds);
    false_alarms(d,2) = 100*sum(post.trials.resp == pre.directions(d) & post_noise_inds)/sum(post_noise_inds);
       
    % d prime
    if numel(pre_trial_inds) > 1 && numel(pre_noise_inds) > 1

        [pre_dp2,pre_beta] = dprime(percent_correct(d,1)/100,false_alarms(d,1)/100,sum(pre_trial_inds));
            
        [post_dp2,post_beta] = dprime(percent_correct(d,2)/100,false_alarms(d,2)/100,sum(post_trial_inds));
        
        dp(d,1) = pre_dp2;
        dp(d,2) = post_dp2;
    else
        dp(d,1) = NaN;
        dp(d,2) = NaN;
    end
    
end

% subplot(2,3,1); hold on;
% plot(direction(b,:),pre_percent_correct(b,:),'o:','color',ColorIt('k'),'markerfacecolor',ColorIt('k'),'linewidth',2);
% plot(direction(b,:),post_percent_correct(b,:),'o-','color',ColorIt('k'),'markerfacecolor',ColorIt('k'),'linewidth',2);
% plot([pre.main_direction pre.main_direction],'k-')
%     
% subplot(2,3,2); hold on;
% plot(direction(b,:),pre_dp(b,:),'o:','color',ColorIt('k'),'markerfacecolor',ColorIt('k'),'linewidth',2);
% plot(direction(b,:),post_dp(b,:),'o-','color',ColorIt('k'),'markerfacecolor',ColorIt('k'),'linewidth',2);
% plot([pre.main_direction pre.main_direction],'k-')


subplot(2,3,1); hold on;
lh = legend(h,cellstr(num2str(coherence(:,1), '%-.1d')),'location','bestoutside');
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
set(gca,'Xtick',pre.directions)
box on;

subplot(2,3,4); hold on;
lh = legend(h2,cellstr(num2str(coherence(:,1), '%-.1d')),'location','bestoutside');
hlt = text(...
    'Parent', lh.DecorationContainer, ...
    'String', 'coherence', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'Position', [0.5, 1.05, 0], ...
    'Units', 'normalized');
ylabel('sensitivity');
xlabel('motion direction');
set(gca,'Xtick',pre.directions)
ylim([0 5]);
box on;

subplot(2,3,2); hold on;
hb = bar(bar_height_coherence);
ylabel('percent correct');
xlabel('coherence');
legend(hb,'pre','post','location','bestoutside');
box on;
set(gca,'Xtick',1:size(bar_height_coherence,1),'xticklabel',[num2cell(pre.coherences) {'all'}])


subplot(2,3,5); hold on;
hb = bar(bar_height_coherence_dp);
ylabel('sensitivity');
xlabel('coherence');
legend(hb,'pre','post','location','bestoutside');
box on;
set(gca,'Xtick',1:size(bar_height_coherence,1),'xticklabel',[num2cell(pre.coherences) {'all'}])


subplot(2,3,3); hold on;
hb = bar(percent_correct);
ylabel('percent correct');
xlabel('direction');
legend(hb,'pre','post','location','bestoutside');
box on;
set(gca,'Xtick',1:numel(pre.directions),'xticklabel',pre.directions)

subplot(2,3,6); hold on;
hb = bar(dp);
ylabel('sensitivity');
xlabel('direction');
legend(hb,'pre','post','location','bestoutside');
box on;
set(gca,'Xtick',1:numel(pre.directions),'xticklabel',pre.directions)

