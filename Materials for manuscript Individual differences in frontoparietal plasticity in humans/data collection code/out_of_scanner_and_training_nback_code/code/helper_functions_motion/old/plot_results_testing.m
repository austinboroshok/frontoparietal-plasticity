function plot_results_testing(dat)
%
%
close all;

scell = dat.scell;

figure(1); hold on;
suptitle(dat.test_type);
set(gcf,'color',[1 1 1]);

figure(2); hold on;
switch dat.test_type
    
    case 'pretest'
        suptitle(dat.test_type);
    case 'posttest'
        suptitle([dat.test_type ' -- trained on ' num2str(dat.main_direction)]);
end
set(gcf,'color',[1 1 1]);

for d = 1:length(dat.directions)
    
    % staircases
    figure(1); hold on;
    subplot(2,2,d); hold on; title(num2str(dat.directions(d)))
    for s = 1:length(scell)
        
        if dat.directions(d) == get(scell{s},'direction')
            
            Scoherences = get(scell{s},'coherences');

            plot(1:length(Scoherences),Scoherences,'o-','color',ColorIt(mod(9,s)+1),'markerfacecolor',ColorIt(mod(9,s)+1))
            xlabel('trial');
            ylabel('coherence');
            ylim([0 30])
        end
        
    end
    
    % p functions
    coherences = dat.pfitM(d).coherences;
    percent_yes = dat.pfitM(d).percent_yes;
    threshold(d) = norminv(0.75,dat.mu(d),sqrt(dat.var(d)));
    
    figure(2); hold on;
    plot(coherences,normcdf(coherences,dat.mu(d),sqrt(dat.var(d))),'-','color',ColorIt(d))
    h(d) = plot(coherences,percent_yes,'o','color',ColorIt('k'),'markerfacecolor',ColorIt(d));
    plot([0 dat.mu(d)],[0.5 .5],':','color',ColorIt(d))
    plot([dat.mu(d) dat.mu(d)],[0 .5],':','color',ColorIt(d))
    plot(dat.mu(d),.5,'s','color',ColorIt('k'),'markerfacecolor',ColorIt(d))
    plot([0 threshold(d)],[0.75 .75],'--','color',ColorIt(d))
    plot([threshold(d) threshold(d)],[0 .75],'--','color',ColorIt(d))
    plot(threshold(d),.75,'^','color',ColorIt('k'),'markerfacecolor',ColorIt(d))
    xlabel('coherence'); 
    ylabel('proportion yes');
    
end

lh = legend(h,cellstr(num2str(dat.directions', '%-d')),'location','southeast');

hlt = text(...
    'Parent', lh.DecorationContainer, ...
    'String', 'motion direction', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'Position', [0.5, 1.05, 0], ...
    'Units', 'normalized');


figure(3); hold on;
suptitle(dat.test_type);
set(gcf,'color',[1 1 1]);

bar(dat.directions,threshold);

figure(1);
saveas(gcf,['../data/' dat.subj '/staircases_' strrep(dat.fileName,'mat','pdf')]);

figure(2);
saveas(gcf,['../data/' dat.subj '/pfuncs_' strrep(dat.fileName,'mat','pdf')]);

figure(3);
saveas(gcf,['../data/' dat.subj '/thresholds_' strrep(dat.fileName,'mat','pdf')]);

% for b = 1:dat.block
%
%     for d = 1:length(dat.directions)
%
%         coherence(b,d) = dat.coherences(b);
%         direction(b,d) = dat.directions(d);
%
%         trial_inds = dat.trials.block == b & dat.trials.direction == direction(b,d) & ~isnan(dat.trials.respCode);
%
%         signal_trials = find(trial_inds & dat.trials.coherence > 0);
%         noise_trials  = find(trial_inds & dat.trials.coherence == 0);
%
%         if numel(signal_trials) > 1 && numel(noise_trials) > 1
%             hits            = sum(dat.trials.isCorrect(signal_trials))/numel(signal_trials);
%             false_alarms    = sum(~dat.trials.isCorrect(noise_trials))/numel(noise_trials);
%
%             [dp(b,d),beta(b,d)] = dprime(hits,false_alarms,numel(signal_trials));
%             %percent_detection(c,d) = 100*sum(dat.trials.respCode(trial_inds) == 1)/numel(trial_inds);
%         else
%             dp(b,d) = NaN;
%         end
%
%     end
%
%     h(b) = plot(direction(b,:),dp(b,:),'o-','color',ColorIt(b),'markerfacecolor',ColorIt(b));
%
% end
%
% lh = legend(h,cellstr(num2str(coherence(:,1), '%-d')),'location','northeastoutside');
% hlt = text(...
%     'Parent', lh.DecorationContainer, ...
%     'String', 'percent coherence', ...
%     'HorizontalAlignment', 'center', ...
%     'VerticalAlignment', 'bottom', ...
%     'Position', [0.5, 1.05, 0], ...
%     'Units', 'normalized');
% ylabel('sensitivity (dprime)');
% xlabel('motion direction');
% box on;
