#!/bin/bash

sub_id=$1
echo $sub_id
outdir=/your_output_dir/${sub_id}

for sub in ${outdoor}; do

# Extract mean intensities for your ROIs from the 'Myelin Map' image 
fslstats ${outdir}/${sub}/MM_in_T1space_masked_csf_bone.nii.gz -k ${outdir}/${sub}/yourROI_inT1space.nii.gz -P 50 >> ${outdir}/${sub}/your_output_textfile.txt

done


