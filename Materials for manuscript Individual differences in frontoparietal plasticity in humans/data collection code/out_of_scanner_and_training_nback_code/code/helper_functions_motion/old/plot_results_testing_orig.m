function plot_results_testing(dat)
%
% 

figure; hold on;
title(dat.test_type);
set(gcf,'color',[1 1 1]);
%for each block
    
for b = 1:dat.block

    for d = 1:length(dat.directions)

        coherence(b,d) = dat.coherences(b);
        direction(b,d) = dat.directions(d);

        trial_inds = dat.trials.block == b & dat.trials.direction == direction(b,d) & ~isnan(dat.trials.respCode);

        signal_trials = find(trial_inds & dat.trials.coherence > 0);
        noise_trials  = find(trial_inds & dat.trials.coherence == 0);
        
        if numel(signal_trials) > 1 && numel(noise_trials) > 1
            hits            = sum(dat.trials.isCorrect(signal_trials))/numel(signal_trials);
            false_alarms    = sum(~dat.trials.isCorrect(noise_trials))/numel(noise_trials);
            
            [dp(b,d),beta(b,d)] = dprime(hits,false_alarms,numel(signal_trials));
            %percent_detection(c,d) = 100*sum(dat.trials.respCode(trial_inds) == 1)/numel(trial_inds);
        else
            dp(b,d) = NaN;
        end

    end

    h(b) = plot(direction(b,:),dp(b,:),'o-','color',ColorIt(b),'markerfacecolor',ColorIt(b));

end

lh = legend(h,cellstr(num2str(coherence(:,1), '%-d')),'location','northeastoutside');
hlt = text(...
    'Parent', lh.DecorationContainer, ...
    'String', 'percent coherence', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'Position', [0.5, 1.05, 0], ...
    'Units', 'normalized');
ylabel('sensitivity (dprime)');
xlabel('motion direction');
box on;
