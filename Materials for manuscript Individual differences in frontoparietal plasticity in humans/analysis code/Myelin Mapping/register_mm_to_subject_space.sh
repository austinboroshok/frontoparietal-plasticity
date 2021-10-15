#!/bin/bash

## The output MRTool files named em* and mr* are in native subject space, but have been centered and rotated to be in alignment with the MNI template and are thus not in raw T1 space.
## The purpose of this script is to register the file emt1w_on_t2w.nii (which corresponds to the final unbiased and calibrated T1w/T2 ratio file) to the original raw T1 volume's space.

for subj in dir; do

  # Define the path where the MRTool output mt1w.nii file is located at per subject
  mt1w=/path_to_mm_dir/sub/mrtool_results/mt1w.nii

  # Define where each subject's raw t1w.nii file is located at
  t1=/path_to_sub_T1w

  # Define the path where the MRTool output emt1w_on_t2w.nii file is located at per subject
  t1w_t2w=/path_to_mm_dir/sub/mrtool_results/emt1w_on_t2w.nii

  # Apply FSL's flirt tool to linearly register the intensity non-uniformity (INU) corrected mt1w.nii file to the raw T1 space
  flirt -in $mt1w -ref $t1 -out /path_to_mm_dir/sub/mrtool_results/t1w_in_raw_t1_space.nii -omat /path_to_mm_dir/sub/mrtool_results/mt1w_in_raw_t1_space.mat -dof 6

  # Apply the output registration matrix from the line above to register the emt1w_on_t2w.nii file onto raw T1 space
  flirt -in $t1w_t2w -ref $t1 -out /path_to_mm_dir/sub/mrtool_results/emt1w_on_t2w_in_raw_T1_space.nii.gz -init /path_to_mm_dir/sub/mrtool_results/mt1w_in_raw_t1_space.mat -applyxfm

done

