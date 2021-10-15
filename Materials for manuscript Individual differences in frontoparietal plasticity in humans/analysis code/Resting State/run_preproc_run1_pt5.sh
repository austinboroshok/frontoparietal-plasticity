#!/bin/sh

### Written by Anne Park (Changing Brain Lab)
### Script is used to run the rsfmri_vol_surface_preprocessing_nipy_CBL_modification.py script
### Inputs for MRI files follow BIDS format

# Used miniconda to create Python environment; contact author for more information

SUB=$1
SCAN_NUM=$2
RUN_NUM=$3

SCRIPTS_DIR=/your_scripts_dir

echo "python ${SCRIPTS_DIR}/rsfmri_vol_surface_preprocessing_nipy_CBL_modification.py -d /your_dicoms_dir/${SUB}/001_00*${SCAN_NUM}_*001.dcm -f /your_bids_dir/sub-${SUB}/func/sub-${SUB}_task-rest_run-0${RUN_NUM}_bold.nii.gz -t ${SCRIPTS_DIR}/OASIS-30_Atropos_template_in_MNI152_2mm.nii.gz -s ${SUB} --subjects_dir /your_bids_dir/derivates/freesurfer/ -o output_dir -w working_dir"

python ${SCRIPTS_DIR}/rsfmri_vol_surface_preprocessing_nipy_CBL_modification.py -d /your_dicoms_dir/${SUB}/001_00*${SCAN_NUM}_*001.dcm -f /your_bids_dir/sub-${SUB}/func/sub-${SUB}_task-rest_run-0${RUN_NUM}_bold.nii.gz -t ${SCRIPTS_DIR}/OASIS-30_Atropos_template_in_MNI152_2mm.nii.gz -s ${SUB} --subjects_dir /your_bids_dir/derivates/freesurfer/ -o output_dir -w working_dir
