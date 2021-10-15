#!/bin/bash

sub_id=$1
echo $sub_id

workingdir=~/your_working_dir
mkdir ~/your_myelin_dir/${sub_id}
myelindir=/your_myelin_dir
myelinmapdir=${myelindir}/your_t1t2ratiomap_dir
roidir=/your_roi_dir
outdir=/your_output_dir/${sub_id}
freesurferdir=/your_bids_dir/derivates/freesurfer_recon/
T2=/your_bids_dir/sub-${sub_id}/anat/sub-${sub_id}_run-01_T2w.nii.gz
T1=/your_bids_dir/sub-${sub_id}/anat/sub-${sub_id}_highres_brain.nii.gz
#The following variable accesses the MRTool directory from the Ganzetti et al (2014) paper
MNI_152=/your_MRTool_dir/MRTool/template/mni_icbm152_t1_tal_nlin_sym_09a.nii
cp ${T2} ${outdir}
cp ${T1} ${outdir}
cp ${roidir}/L_lPFC_roi.nii.gz ${outdir}
cp ${roidir}/R_lPFC_roi.nii.gz ${outdir}
cp ${roidir}/mPFC_roi.nii.gz ${outdir}
cp ${roidir}/parietal_roi.nii.gz ${outdir}
cp ${roidir}/striatum_roi.nii.gz ${outdir}


for sub in /your_subject_dir/; do

# Converting freesurfer surface to NIFTI format, converting surface to subject T1 space
echo "converting ${sub_id} aparcaseg to nifti and converting that to T1 space with flirt"
mri_convert ${freesurferdir}/${sub_id}/mri/aparc+aseg.mgz ${outdir}/aparc_aseg.nii.gz
flirt -in ${outdir}/aparc_aseg.nii.gz -ref ${T1} -interp nearestneighbour -o ${outdir}/aparc_aseg_t1space.nii.gz

# Create lateral ventricle mask
echo "masking out csf, wm, and cc from ${sub_id} aparcaseg file"
fslmaths ${outdir}/aparc_aseg_t1space.nii.gz -thr 4 -uthr 4 ${outdir}/aparc_aseg_L_lventricle.nii.gz
fslmaths ${outdir}/aparc_aseg_t1space.nii.gz -thr 43 -uthr 43 ${outdir}/aparc_aseg_R_lventricle.nii.gz
fslmaths ${outdir}/aparc_aseg_L_lventricle.nii.gz -add ${outdir}/aparc_aseg_R_lventricle.nii.gz ${outdir}/aparc_aseg_lateralventricles.nii.gz

# Create CSF mask
fslmaths ${outdir}/aparc_aseg_t1space.nii.gz -thr 24 -uthr 24 ${outdir}/aparc_aseg_csf.nii.gz

# Create white matter mask
fslmaths ${outdir}/aparc_aseg_t1space.nii.gz -thr 2 -uthr 2 ${outdir}/aparc_aseg_lh_wm.nii.gz
fslmaths ${outdir}/aparc_aseg_t1space.nii.gz -thr 41 -uthr 41 ${outdir}/aparc_aseg_rh_wm.nii.gz
fslmaths ${outdir}/aparc_aseg_lh_wm.nii.gz -add ${outdir}/aparc_aseg_rh_wm.nii.gz ${outdir}/aparc_aseg_whitematter.nii.gz

# Create corpus callosum mask and add up corpus callosum parts into single image
fslmaths ${outdir}/aparc_aseg_t1space.nii.gz -thr 251 -uthr 251 ${outdir}/aparc_aseg_cc_posterior.nii.gz
fslmaths ${outdir}/aparc_aseg_t1space.nii.gz -thr 252 -uthr 252 ${outdir}/aparc_aseg_cc_mid_posterior.nii.gz
fslmaths ${outdir}/aparc_aseg_t1space.nii.gz -thr 253 -uthr 253 ${outdir}/aparc_aseg_cc_central.nii.gz
fslmaths ${outdir}/aparc_aseg_t1space.nii.gz -thr 254 -uthr 254 ${outdir}/aparc_aseg_cc_mid_anterior.nii.gz
fslmaths ${outdir}/aparc_aseg_t1space.nii.gz -thr 255 -uthr 255 ${outdir}/aparc_aseg_cc_anterior.nii.gz
fslmaths ${outdir}/aparc_aseg_cc_posterior.nii.gz -add ${outdir}/aparc_aseg_cc_mid_posterior.nii.gz ${outdir}/posterior_midposterior.nii.gz
fslmaths ${outdir}/posterior_midposterior.nii.gz -add ${outdir}/aparc_aseg_cc_central.nii.gz ${outdir}/posterior_midposterior_central.nii.gz
fslmaths ${outdir}/posterior_midposterior_central.nii.gz -add ${outdir}/aparc_aseg_cc_mid_anterior.nii.gz ${outdir}/posterior_midposterior_central_midanterior.nii.gz
fslmaths ${outdir}/posterior_midposterior_central_midanterior.nii.gz -add ${outdir}/aparc_aseg_cc_anterior.nii.gz ${outdir}/aparc_aseg_corpuscallosum.nii.gz

# Combine CC, WM, CSF, & lateral ventricles masks into single image
fslmaths ${outdir}/aparc_aseg_corpuscallosum.nii.gz -add ${outdir}/aparc_aseg_whitematter.nii.gz ${outdir}/ccpluswm.nii.gz
fslmaths ${outdir}/ccpluswm.nii.gz -add ${outdir}/aparc_aseg_csf.nii.gz ${outdir}/ccpluswmpluscsf.nii.gz
fslmaths ${outdir}/ccpluswmpluscsf.nii.gz -add ${outdir}/aparc_aseg_lateralventricles.nii.gz ${outdir}/csf_wm_cc_ventricles_mask.nii.gz

# Mask out CSF/WM/CC/lateral ventircles from the aparc_aseg file in T1 space and the 'Myelin Map' image
fslmaths ${outdir}/aparc_aseg_t1space.nii.gz -sub ${outdir}/csf_wm_cc_ventricles_mask.nii.gz ${outdir}/aparc_aseg_t1space_masked.nii.gz
echo "masking MM with csf/wmm/cc/lateral ventricles mask"

fslmaths ${myelinmapdir}/mrtool_results/emt1w_on_t2w_in_raw_t1_space.nii.gz -mas ${outdir}/aparc_aseg_t1space_masked.nii.gz ${outdir}/${sub}/MM_in_T1space_masked_csf_bone.nii.gz 

done

#########################################
#########################################

### Use following code if you need to inverse transform ROIs to subject space (MM pipeline is in T1 space, so ROIs cannot be in MNI space)

# Move T1 to MNI space, needed for next inverse transformation step
echo "antsTransforming ${sub_id} 's T1 to standard (MNI) space"
antsRegistration --collapse-output-transforms 1 --dimensionality 3 --float 1 --initial-moving-transform [ ${MNI_152}, ${T1}, 1 ] --initialize-transforms-per-stage 0 --interpolation Linear --output [ ${outdir}/output_, ${outdir}/T12standard.nii.gz ] --transform Rigid[ 0.1 ] --metric Mattes[ ${MNI_152}, ${T1}, 1, 32, Regular, 0.3 ] --convergence [ 10000x11110x11110, 1e-08, 20 ] --smoothing-sigmas 4.0x2.0x1.0vox --shrink-factors 3x2x1 --use-estimate-learning-rate-once 1 --use-histogram-matching 0 --transform Affine[ 0.1 ] --metric Mattes[ ${MNI_152}, ${T1}, 1, 32, Regular, 0.3 ] --convergence [ 10000x11110x11110, 1e-08, 20 ] --smoothing-sigmas 4.0x2.0x1.0vox --shrink-factors 3x2x1 --use-estimate-learning-rate-once 1 --use-histogram-matching 0 --transform SyN[ 0.2, 3.0, 0.0 ] --metric Mattes[ ${MNI_152}, ${T1}, 0.5, 32 ] --metric CC[ ${MNI_152}, ${T1}, 0.5, 4 ] --convergence [ 100x30x20, -0.01, 5 ] --smoothing-sigmas 1.0x0.5x0.0vox --shrink-factors 4x2x1 --use-estimate-learning-rate-once 1 --use-histogram-matching 1 --winsorize-image-intensities [ 0.005, 0.995 ]  --write-composite-transform 1

# Inverse transformation MNI space-ROIs into T1 (subject) space (ROIs derived from 2>1 contrast during Scan A activation map)
echo "inverse transforming 5 task-based ROIs into T1 space"
antsApplyTransforms --float --default-value 0 --input ${outdir}/L_lPFC_roi.nii.gz --input-image-type 0 --interpolation NearestNeighbor --output ${outdir}/L_lPFC_T1space.nii.gz --reference-image ${T1} --transform ${outdir}/output_InverseComposite.h5
antsApplyTransforms --float --default-value 0 --input ${outdir}/R_lPFC_roi.nii.gz --input-image-type 0 --interpolation NearestNeighbor --output ${outdir}/R_lPFC_T1space.nii.gz --reference-image ${T1} --transform ${outdir}/output_InverseComposite.h5
antsApplyTransforms --float --default-value 0 --input ${outdir}/mPFC_roi.nii.gz --input-image-type 0 --interpolation NearestNeighbor --output ${outdir}/mPFC_T1space.nii.gz --reference-image ${T1} --transform ${outdir}/output_InverseComposite.h5
antsApplyTransforms --float --default-value 0 --input ${outdir}/parietal_roi.nii.gz --input-image-type 0 --interpolation NearestNeighbor --output ${outdir}/parietal_T1space.nii.gz --reference-image ${T1} --transform ${outdir}/output_InverseComposite.h5
antsApplyTransforms --float --default-value 0 --input ${outdir}/striatum_roi.nii.gz --input-image-type 0 --interpolation NearestNeighbor --output ${outdir}/striatum_T1space.nii.gz --reference-image ${T1} --transform ${outdir}/output_InverseComposite.h5

done

