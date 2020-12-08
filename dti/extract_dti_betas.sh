##set python environment by running bpd_env first

#!/bin/sh

data_dir=/data/jux/mackey_group/austin/BPD/TRACULA
sub_list=/data/jux/mackey_group/austin/BPD/TRACULA/scripts/sublist.txt
roi_list=/data/jux/mackey_group/austin/BPD/TRACULA/rois/original_task_rois/roi_list.txt


for sub in `cat $sub_list`; do
for roi in `cat $roi_list`; do
for analysis in FA L1 L2 L3 MD; do

echo "`fslstats -t ${data_dir}/${sub}/dmri/mni/dtifit_${analysis}.bbr.nii.gz -k ${data_dir}/rois/${roi}_bin_1mm.nii.gz -M`" >> ${data_dir}/rois/${roi}_${analysis}.txt

done
done
done
