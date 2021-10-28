clear all; close all;

% path to raw Nback data
datapath = '~/N-Back/data_behav/';

% read in REDCap data
T = readtable('~/Downloads/N-back/nback_behavioral_input.csv');

% make new table, with same record ID column
TNew = table;
TNew.record_id = T.record_id;

% ge unique subjects
subjs = strrep(T.record_id,'BPD','');

for s = 1:length(subjs)
    
    % initialize nback calculatables as NaNs, then we will fill in if this
    % participant has these data
        TNew.first_2_RT(s) = NaN;
    TNew.first_2_pc(s) = NaN;
    TNew.first_2_hit(s) = NaN;
    TNew.first_2_miss(s) = NaN;
    TNew.first_2_fa(s) = NaN;
    TNew.first_2_cr(s) = NaN;
    TNew.first_2_dp(s) = NaN;
    TNew.first_2_omit(s) = NaN;
    
    TNew.first_3_RT(s) = NaN;
    TNew.first_3_pc(s) = NaN;
    TNew.first_3_hit(s) = NaN;
    TNew.first_3_miss(s) = NaN;
    TNew.first_3_fa(s) = NaN;
    TNew.first_3_cr(s) = NaN;
    TNew.first_3_dp(s) = NaN;
    TNew.first_3_omit(s) = NaN;
    
    TNew.first_4_RT(s) = NaN;
    TNew.first_4_pc(s) = NaN;
    TNew.first_4_hit(s) = NaN;
    TNew.first_4_miss(s) = NaN;
    TNew.first_4_fa(s) = NaN;
    TNew.first_4_cr(s) = NaN;
    TNew.first_4_dp(s) = NaN;
    TNew.first_4_omit(s) = NaN;
    
    TNew.second_2_RT(s) = NaN;
    TNew.second_2_pc(s) = NaN;
    TNew.second_2_hit(s) = NaN;
    TNew.second_2_miss(s) = NaN;
    TNew.second_2_fa(s) = NaN;
    TNew.second_2_cr(s) = NaN;
    TNew.second_2_dp(s) = NaN;
    TNew.second_2_omit(s) = NaN;
    
    TNew.second_3_RT(s) = NaN;
    TNew.second_3_pc(s) = NaN;
    TNew.second_3_hit(s) = NaN;
    TNew.second_3_miss(s) = NaN;
    TNew.second_3_fa(s) = NaN;
    TNew.second_3_cr(s) = NaN;
    TNew.second_3_dp(s) = NaN;
    TNew.second_3_omit(s) = NaN;
    
    TNew.second_4_RT(s) = NaN;
    TNew.second_4_pc(s) = NaN;
    TNew.second_4_hit(s) = NaN;
    TNew.second_4_miss(s) = NaN;
    TNew.second_4_fa(s) = NaN;
    TNew.second_4_cr(s) = NaN;
    TNew.second_4_dp(s) = NaN;
    TNew.second_4_omit(s) = NaN;
    
    TNew.third_2_RT(s) = NaN;
    TNew.third_2_pc(s) = NaN;
    TNew.third_2_hit(s) = NaN;
    TNew.third_2_miss(s) = NaN;
    TNew.third_2_fa(s) = NaN;
    TNew.third_2_cr(s) = NaN;
    TNew.third_2_dp(s) = NaN;
    TNew.third_2_omit(s) = NaN;
    
    TNew.third_3_RT(s) = NaN;
    TNew.third_3_pc(s) = NaN;
    TNew.third_3_hit(s) = NaN;
    TNew.third_3_miss(s) = NaN;
    TNew.third_3_fa(s) = NaN;
    TNew.third_3_cr(s) = NaN;
    TNew.third_3_dp(s) = NaN;
    TNew.third_3_omit(s) = NaN;
    
    TNew.third_4_RT(s) = NaN;
    TNew.third_4_pc(s) = NaN;
    TNew.third_4_hit(s) = NaN;
    TNew.third_4_miss(s) = NaN;
    TNew.third_4_fa(s) = NaN;
    TNew.third_4_cr(s) = NaN;
    TNew.third_4_dp(s) = NaN;
    TNew.third_4_omit(s) = NaN;

    TNew.fourth_2_RT(s) = NaN;
    TNew.fourth_2_pc(s) = NaN;
    TNew.fourth_2_hit(s) = NaN;
    TNew.fourth_2_miss(s) = NaN;
    TNew.fourth_2_fa(s) = NaN;
    TNew.fourth_2_cr(s) = NaN;
    TNew.fourth_2_dp(s) = NaN;
    TNew.fourth_2_omit(s) = NaN;
    
    TNew.fourth_3_RT(s) = NaN;
    TNew.fourth_3_pc(s) = NaN;
    TNew.fourth_3_hit(s) = NaN;
    TNew.fourth_3_miss(s) = NaN;
    TNew.fourth_3_fa(s) = NaN;
    TNew.fourth_3_cr(s) = NaN;
    TNew.fourth_3_dp(s) = NaN;
    TNew.fourth_3_omit(s) = NaN;
    
    TNew.fourth_4_RT(s) = NaN;
    TNew.fourth_4_pc(s) = NaN;
    TNew.fourth_4_hit(s) = NaN;
    TNew.fourth_4_miss(s) = NaN;
    TNew.fourth_4_fa(s) = NaN;
    TNew.fourth_4_cr(s) = NaN;
    TNew.fourth_4_dp(s) = NaN;
    TNew.fourth_4_omit(s) = NaN;
    
    % look for nback data
    prefileN = dir([datapath 'BPD' subjs{s} '/*' subjs{s} '_first*.mat']);
    
    % if the data exist
    if ~isempty(prefileN)
        
        % give option to select input file if there is more than 1 match
        if length(prefileN) > 1
        [file, path] = uigetfile([datapath 'BPD' subjs{s} '/*' subjs{s} '_pretest*.mat'],'Select pre file');
        prefileN = dir([path, file]);
        
        end
        
        % load it
        load([datapath 'BPD' subjs{s} '/' prefileN.name]);
        
        [omitted_trials,percent_correct,hits,false_alarms,misses,crs,dp,median_rt] = plot_results_testing(dat, datapath, subjs{s});
        
        % add values to table
        TNew.pre_2_RT(s) = median_rt(1);
        TNew.pre_2_pc(s) = percent_correct(1);
        TNew.pre_2_hit(s) = hits(1);
        TNew.pre_2_miss(s) = misses(1);
        TNew.pre_2_fa(s) = false_alarms(1);
        TNew.pre_2_cr(s) = crs(1);
        TNew.pre_2_dp(s) = dp(1);
        TNew.pre_2_omit(s) = omitted_trials(1);
        
        TNew.pre_3_RT(s) = median_rt(2);
        TNew.pre_3_pc(s) = percent_correct(2);
        TNew.pre_3_hit(s) = hits(2);
        TNew.pre_3_miss(s) = misses(2);
        TNew.pre_3_fa(s) = false_alarms(2);
        TNew.pre_3_cr(s) = crs(2);
        TNew.pre_3_dp(s) = dp(2);
        TNew.pre_3_omit(s) = omitted_trials(2);
        
        TNew.pre_4_RT(s) = median_rt(3);
        TNew.pre_4_pc(s) = percent_correct(3);
        TNew.pre_4_hit(s) = hits(3);
        TNew.pre_4_miss(s) = misses(3);
        TNew.pre_4_fa(s) = false_alarms(3);
        TNew.pre_4_cr(s) = crs(3);
        TNew.pre_4_dp(s) = dp(3);
        TNew.pre_4_omit(s) = omitted_trials(3);
        
    end
    
        % look for nback data
    postfileN = dir([datapath 'BPD' subjs{s} '/*' subjs{s} '_posttest*.mat']);
    
    % if the data exist
    if ~isempty(postfileN)
        
        % give option to select input file if there is more than 1 match
        if length(postfileN) > 1
        [file, path] = uigetfile([datapath 'BPD' subjs{s} '/*' subjs{s} '_posttest*.mat'],'Select post file');
        postfileN = dir([path, file]);
        
        end
        
        % load it
        load([datapath 'BPD' subjs{s} '/' postfileN.name]);
        
        [omitted_trials,percent_correct,hits,false_alarms,misses,crs,dp,median_rt] = plot_results_testing(dat, datapath, subjs{s});
        
        % add values to table
        TNew.post_2_RT(s) = median_rt(1);
        TNew.post_2_pc(s) = percent_correct(1);
        TNew.post_2_hit(s) = hits(1);
        TNew.post_2_miss(s) = misses(1);
        TNew.post_2_fa(s) = false_alarms(1);
        TNew.post_2_cr(s) = crs(1);
        TNew.post_2_dp(s) = dp(1);
        TNew.post_2_omit(s) = omitted_trials(1);
        
        TNew.post_3_RT(s) = median_rt(2);
        TNew.post_3_pc(s) = percent_correct(2);
        TNew.post_3_hit(s) = hits(2);
        TNew.post_3_miss(s) = misses(2);
        TNew.post_3_fa(s) = false_alarms(2);
        TNew.post_3_cr(s) = crs(2);
        TNew.post_3_dp(s) = dp(2);
        TNew.post_3_omit(s) = omitted_trials(2);
        
        TNew.post_4_RT(s) = median_rt(3);
        TNew.post_4_pc(s) = percent_correct(3);
        TNew.post_4_hit(s) = hits(3);
        TNew.post_4_miss(s) = misses(3);
        TNew.post_4_fa(s) = false_alarms(3);
        TNew.post_4_cr(s) = crs(3);
        TNew.post_4_dp(s) = dp(3);
        TNew.post_4_omit(s) = omitted_trials(3);
        
    end
    
end

writetable(TNew,[datapath, 'nback_corrected_', date, '.csv']);