#!/bin/bash
## The purpose of this script is to submit matlab scripts with qsub

matlab_file_path=/your_working_dir/T1_T2_ratio_job.m
# echo ${matlab_file_path}

# Run matlab from the terminal
matlab -nodisplay -nosplash -nodesktop -r "run('${matlab_file_path}');exit;"
