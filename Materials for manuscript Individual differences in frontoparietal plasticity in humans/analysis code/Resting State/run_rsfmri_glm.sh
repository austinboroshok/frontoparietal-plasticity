#!/bin/sh

### Written by Anne Park (Changing Brain Lab)
### Scripts takes preprocessed ouput of rsfmri_vol_surface_preprocessing_nipy_CBL_modification.py script and outputs average time series within each ROI for each subject (output file name will be called seed_ts.txt).
### ROI NIFTI files should only contain a single binarized ROI (should not be used with images with multiple ROIs)

# Usage

if [ $# -eq 0 ]; then
echo "Usage: run_rsfmri_glm.sh <data_dir> <sub_list> <roi_list>"
exit
fi

data_dir=${1} # directory containing your preprocessed resting-state data
sub_list=${2} # .txt file containing each subject on separate line
roi_list=${3} # .txt file containing each ROI on separate line

for sub in `cat ${sub_list}`; do

echo ${sub}

for roi in `cat ${roi_list}`; do

mkdir -p ${data_dir}/${sub}/${roi} # creates output directory

fslmeants -i ${data_dir}/${sub}/resting/timeseries/target/rest_01.nii.gz \
-m /PATH/TO/ROI/NIFTI/FILE/${roi}.nii.gz \
-o ${data_dir}/${sub}/${roi}/seed_ts.txt

done

done
