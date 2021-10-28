clear all; close all;

% path to raw Nback data
datapath = '~/Documents/git_repos/N-Back-Scanner/data/';

% read in subject list - must include column on nback counterbalancing order (nback_order)
T = readtable('~/Documents/BPD_subjectlist_11272018.csv');

% make new table, with same record ID column
TNew = table;
TNew.record_id = T.record_id;

% ge unique subjects
subjs = strrep(T.record_id,'BPD','');

for s = 1:length(subjs)
    % initialize nback calculatables as NaNs, then we will fill in if this
    % participant has these data
    TNew.nback_1_pre_nback_RT(s) = NaN;
    TNew.nback_1_pre_nback_pc(s) = NaN;
    TNew.nback_1_pre_nback_hit(s) = NaN;
    TNew.nback_1_pre_nback_miss(s) = NaN;
    TNew.nback_1_pre_nback_fa(s) = NaN;
    TNew.nback_1_pre_nback_cr(s) = NaN;
    TNew.nback_1_pre_nback_dp(s) = NaN;
    TNew.nback_1_pre_nback_omit(s) = NaN;
        
    TNew.nback_2_pre_nback_RT(s) = NaN;
    TNew.nback_2_pre_nback_pc(s) = NaN;
    TNew.nback_2_pre_nback_hit(s) = NaN;
    TNew.nback_2_pre_nback_miss(s) = NaN;
    TNew.nback_2_pre_nback_fa(s) = NaN;
    TNew.nback_2_pre_nback_cr(s) = NaN;
    TNew.nback_2_pre_nback_dp(s) = NaN;
    TNew.nback_2_pre_nback_omit(s) = NaN;
    
    TNew.nback_1_post_nback_RT(s) = NaN;
    TNew.nback_1_post_nback_pc(s) = NaN;
    TNew.nback_1_post_nback_hit(s) = NaN;
    TNew.nback_1_post_nback_miss(s) = NaN;
    TNew.nback_1_post_nback_fa(s) = NaN;
    TNew.nback_1_post_nback_cr(s) = NaN;
    TNew.nback_1_post_nback_dp(s) = NaN;
    TNew.nback_1_post_nback_omit(s) = NaN;
        
    TNew.nback_2_post_nback_RT(s) = NaN;
    TNew.nback_2_post_nback_pc(s) = NaN;
    TNew.nback_2_post_nback_hit(s) = NaN;
    TNew.nback_2_post_nback_miss(s) = NaN;
    TNew.nback_2_post_nback_fa(s) = NaN;
    TNew.nback_2_post_nback_cr(s) = NaN;
    TNew.nback_2_post_nback_dp(s) = NaN;
    TNew.nback_2_post_nback_omit(s) = NaN;
    
    % look for nback data
    if T.nback_order(s) == 1
        letter = 'A';
    elseif T.nback_order(s) == 2
        letter = 'C';
    end
    
    matpath = [datapath 'BPD' subjs{s} letter '/*' subjs{s} letter '*.mat'];
    prefileN = dir(matpath);

    % if the data exist
    if ~isempty(prefileN)
        
        % give option to select input file if there is more than 1 match
        if length(prefileN) > 1
            [file, path] = uigetfile(matpath,'Select .mat file');
            prefileN = dir([path, file]);
        end
        
        % load it
        load([datapath 'BPD' subjs{s} letter '/' prefileN.name]);
        
        [omitted_trials,percent_correct,hits,false_alarms,misses,crs,dp,median_rt] = plot_results_scan_testing(dat, datapath, subjs{s}, letter);
        
        % add values to table
        
        TNew.nback_1_pre_nback_RT(s) = median_rt(1);
        TNew.nback_1_pre_nback_pc(s) = percent_correct(1);
        TNew.nback_1_pre_nback_hit(s) = hits(1);
        TNew.nback_1_pre_nback_miss(s) = misses(1);
        TNew.nback_1_pre_nback_fa(s) = false_alarms(1);
        TNew.nback_1_pre_nback_cr(s) = crs(1);
        TNew.nback_1_pre_nback_dp(s) = dp(1);
        TNew.nback_1_pre_nback_omit(s) = omitted_trials(1);
        
        TNew.nback_2_pre_nback_RT(s) = median_rt(2);
        TNew.nback_2_pre_nback_pc(s) = percent_correct(2);
        TNew.nback_2_pre_nback_hit(s) = hits(2);
        TNew.nback_2_pre_nback_miss(s) = misses(2);
        TNew.nback_2_pre_nback_fa(s) = false_alarms(2);
        TNew.nback_2_pre_nback_cr(s) = crs(2);
        TNew.nback_2_pre_nback_dp(s) = dp(2);
        TNew.nback_2_pre_nback_omit(s) = omitted_trials(2);
        
    end
    
    % look for nback data
    if T.nback_order(s) == 1
        letter = 'B';
    elseif T.nback_order(s) == 2
        letter = 'D';
    end
    
    matpath = [datapath 'BPD' subjs{s} letter '/*' subjs{s} letter '*.mat'];
    prefileN = dir(matpath);

    % if the data exist
    if ~isempty(prefileN)
        
        % give option to select input file if there is more than 1 match
        if length(prefileN) > 1
            [file, path] = uigetfile(matpath,'Select .mat file');
            prefileN = dir([path, file]);
        end
        
        % load it
        load([datapath 'BPD' subjs{s} letter '/' prefileN.name]);
        
        [omitted_trials,percent_correct,hits,false_alarms,misses,crs,dp,median_rt] = plot_results_scan_testing(dat, datapath, subjs{s}, letter);
        
        % add values to table
        TNew.nback_1_post_nback_RT(s) = median_rt(1);
        TNew.nback_1_post_nback_pc(s) = percent_correct(1);
        TNew.nback_1_post_nback_hit(s) = hits(1);
        TNew.nback_1_post_nback_miss(s) = misses(1);
        TNew.nback_1_post_nback_fa(s) = false_alarms(1);
        TNew.nback_1_post_nback_cr(s) = crs(1);
        TNew.nback_1_post_nback_dp(s) = dp(1);
        TNew.nback_1_post_nback_omit(s) = omitted_trials(1);
        
        TNew.nback_2_post_nback_RT(s) = median_rt(2);
        TNew.nback_2_post_nback_pc(s) = percent_correct(2);
        TNew.nback_2_post_nback_hit(s) = hits(2);
        TNew.nback_2_post_nback_miss(s) = misses(2);
        TNew.nback_2_post_nback_fa(s) = false_alarms(2);
        TNew.nback_2_post_nback_cr(s) = crs(2);
        TNew.nback_2_post_nback_dp(s) = dp(2);
        TNew.nback_2_post_nback_omit(s) = omitted_trials(2);
        
    end
    
end

writetable(TNew,[datapath, 'nback_scanner_corrected_', date, '.csv']);