%% CSV Writer for pretest and posttest stats.
%Please remember to change the participant ID of the CSV and move it out of the
%helper_functions folder once you 
%put the CSV on Box. 

%Use in conjunction with plot_results_preposttest_comparison so the variables are loaded- after
%running that function with the participant whose CSV you are making, run
%this script. Once the CSV is made, move to to the desktop (just drag it),
%open it and add one extra row and two extra columns (shift the cells two to the right and one down.), one
%copy and paste the headers from another csv file in box. fill in record_id and trained appropriately
%record_id = BPD_XXXX
%trained = 1 if they did training, 0 if they did not do training

headers = {'pre_2_hit','pre_2_miss','pre_2_fa','pre_2_cr','pre_2_dp','pre_3_hit', 'pre_3_miss','pre_3_fa','pre_3_cr','pre_3_dp','pre_4_hit','pre_4_miss','pre_4_fa','pre_4_cr','pre_4_dp','post_2_hit','post_2_miss','post_2_fa','post_2_cr','post_2_dp','post_3_hit','post_3_miss','post_3_fa','post_3_cr','post_3_dp','post_4_hit','post_4_miss','post_4_fa','post_4_cr','post_4_dp'};

data = ([pre_hits(1), 1-pre_hits(1), pre_false_alarms(1), ...
    1-pre_false_alarms(1), pre_dp(1), pre_hits(2), 1-pre_hits(2), pre_false_alarms(2), ...
    1-pre_false_alarms(2), pre_dp(2), pre_hits(3), 1-pre_hits(3), pre_false_alarms(3), 1-pre_false_alarms(3), pre_dp(3)...
    post_hits(1), 1-post_hits(1), post_false_alarms(1), ...
    1-post_false_alarms(1), post_dp(1), post_hits(2), 1-post_hits(2), post_false_alarms(2), ...
    1-post_false_alarms(2), post_dp(2), post_hits(3), 1-post_hits(3), post_false_alarms(3), 1-post_false_alarms(3), post_dp(3)]);

csvwrite_with_headers('test.csv',data,headers);