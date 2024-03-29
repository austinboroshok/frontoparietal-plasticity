#!/usr/bin/env python

### Script modified from public nipype legacy workflow example (found at https://github.com/niflows/nipype1-examples/blob/master/package/niflow/nipype1/examples/rsfmri_vol_surface_preprocessing_nipy.py)
### Major modifications include: using Freesurfer to extract white matter and CSF masks (instead of FSL's FAST as done in the original script); original script includes topup preprocessing steps that were not used in our resting-state pipeline.

"""
=====================================
rsfMRI: ANTS, FS, FSL, NiPy, aCompCor
=====================================


A preprocessing workflow for Siemens resting state data.

This workflow makes use of:

- ANTS
- FreeSurfer
- FSL
- NiPy
- CompCor

For example::

  python rsfmri_preprocessing.py -d /data/12345-34-1.dcm -f /data/Resting.nii
      -s subj001 -o output -p PBS --plugin_args "dict(qsub_args='-q many')"

  or

  python rsfmri_vol_surface_preprocessing.py -f SUB_1024011/E?/func/rest.nii
      -t OASIS-30_Atropos_template_in_MNI152_2mm.nii.gz --TR 2 -s SUB_1024011
      --subjects_dir fsdata --slice_times 0 17 1 18 2 19 3 20 4 21 5 22 6 23
      7 24 8 25 9 26 10 27 11 28 12 29 13 30 14 31 15 32 16 -o .

This workflow takes resting timeseries and a Siemens dicom file corresponding
to it and preprocesses it to produce timeseries coordinates or grayordinates.

For non-Siemens dicoms, provide slice times instead, since the dicom extractor is not guaranteed to work.

This workflow also requires 2mm subcortical atlas and templates that are
available from:

http://mindboggle.info/data.html

specifically the 2mm versions of:

- `Joint Fusion Atlas <http://mindboggle.info/data/atlases/jointfusion/OASIS-TRT-20_jointfusion_DKT31_CMA_labels_in_MNI152_2mm_v2.nii.gz>`_
- `MNI template <http://mindboggle.info/data/templates/ants/OASIS-30_Atropos_template_in_MNI152_2mm.nii.gz>`_

"""

from __future__ import division
from builtins import range

import os

from nipype.interfaces.base import CommandLine
CommandLine.set_default_terminal_output('allatonce')

from dcmstack.extract import default_extractor
from pydicom import read_file

from nipype.interfaces import (fsl, Function, ants, freesurfer, nipy)
from nipype.interfaces.c3 import C3dAffineTool

fsl.FSLCommand.set_default_output_type('NIFTI_GZ')

from nipype import Workflow, Node, MapNode

from nipype.algorithms.rapidart import ArtifactDetect
from nipype.algorithms.misc import TSNR
from nipype.interfaces.utility import Rename, Merge, IdentityInterface
from nipype.utils.filemanip import filename_to_list
from nipype.interfaces.io import DataSink, FreeSurferSource
import nipype.interfaces.freesurfer as fs

import numpy as np
import scipy as sp
import nibabel as nb

imports = ['import os',
           'import nibabel as nb',
           'import numpy as np',
           'import scipy as sp',
           'from nipype.utils.filemanip import filename_to_list, list_to_filename, split_filename',
           'from scipy.special import legendre'
           ]


def get_info(dicom_files):
    """Given a Siemens dicom file return metadata

    Returns
    -------
    RepetitionTime
    Slice Acquisition Times
    Spacing between slices
    """
    meta = default_extractor(read_file(filename_to_list(dicom_files)[0],
                                       stop_before_pixels=True,
                                       force=True))
    return (meta['RepetitionTime'] / 1000., meta['CsaImage.MosaicRefAcqTimes'],
            meta['SpacingBetweenSlices'], meta['CsaImage.BandwidthPerPixelPhaseEncode'],
            meta['AcquisitionMatrix'][0])


def get_info_topup(dicom_files):
    meta = default_extractor(read_file(filename_to_list(dicom_files)[0],
                                       stop_before_pixels=True,
                                       force=True))
    return (meta['CsaImage.BandwidthPerPixelPhaseEncode'],
            meta['AcquisitionMatrix'][0])


def median(in_files):
    """Computes an average of the median of each realigned timeseries

    Parameters
    ----------

    in_files: one or more realigned Nifti 4D time series

    Returns
    -------

    out_file: a 3D Nifti file
    """
    average = None
    for idx, filename in enumerate(filename_to_list(in_files)):
        img = nb.load(filename)
        data = np.median(img.get_data(), axis=3)
        if average is None:
            average = data
        else:
            average = average + data
    median_img = nb.Nifti1Image(average / float(idx + 1), img.affine,
                                img.header)
    filename = os.path.join(os.getcwd(), 'median.nii.gz')
    median_img.to_filename(filename)
    return filename


def bandpass_filter(files, lowpass_freq, highpass_freq, fs):
    """Bandpass filter the input files

    Parameters
    ----------
    files: list of 4d nifti files
    lowpass_freq: cutoff frequency for the low pass filter (in Hz)
    highpass_freq: cutoff frequency for the high pass filter (in Hz)
    fs: sampling rate (in Hz)
    """
    out_files = []
    for filename in filename_to_list(files):
        path, name, ext = split_filename(filename)
        out_file = os.path.join(os.getcwd(), name + '_bp' + ext)
        img = nb.load(filename)
        timepoints = img.shape[-1]
        F = np.zeros((timepoints))
        lowidx = int(timepoints / 2) + 1
        if lowpass_freq > 0:
            lowidx = np.round(float(lowpass_freq) / fs * timepoints)
        highidx = 0
        if highpass_freq > 0:
            highidx = np.round(float(highpass_freq) / fs * timepoints)
        F[int(highidx):int(lowidx)] = 1     # ATP 5/26/17
        F = ((F + F[::-1]) > 0).astype(int)
        data = img.get_data()
        if np.all(F == 1):
            filtered_data = data
        else:
            filtered_data = np.real(np.fft.ifftn(np.fft.fftn(data) * F))
        img_out = nb.Nifti1Image(filtered_data, img.affine, img.header)
        img_out.to_filename(out_file)
        out_files.append(out_file)
    return list_to_filename(out_files)


def motion_regressors(motion_params, order=0, derivatives=1):
    """Compute motion regressors upto given order and derivative

    motion + d(motion)/dt + d2(motion)/dt2 (linear + quadratic)
    """
    out_files = []
    for idx, filename in enumerate(filename_to_list(motion_params)):
        params = np.genfromtxt(filename)
        out_params = params
        for d in range(1, derivatives + 1):
            cparams = np.vstack((np.repeat(params[0, :][None, :], d, axis=0),
                                 params))
            out_params = np.hstack((out_params, np.diff(cparams, d, axis=0)))
        out_params2 = out_params
        for i in range(2, order + 1):
            out_params2 = np.hstack((out_params2, np.power(out_params, i)))
        filename = os.path.join(os.getcwd(), "motion_regressor%02d.txt" % idx)
        np.savetxt(filename, out_params2, fmt=str("%.10f"))     # ATP 5/26/17
        out_files.append(filename)
    return out_files


def build_filter1(motion_params, comp_norm, outliers, detrend_poly=None):
    """Builds a regressor set comprisong motion parameters, composite norm and
    outliers

    The outliers are added as a single time point column for each outlier


    Parameters
    ----------

    motion_params: a text file containing motion parameters and its derivatives
    comp_norm: a text file containing the composite norm
    outliers: a text file containing 0-based outlier indices
    detrend_poly: number of polynomials to add to detrend

    Returns
    -------
    components_file: a text file containing all the regressors
    """
    out_files = []
    for idx, filename in enumerate(filename_to_list(motion_params)):
        params = np.genfromtxt(filename)
        norm_val = np.genfromtxt(filename_to_list(comp_norm)[idx])
        out_params = np.hstack((params, norm_val[:, None]))
        try:
            outlier_val = np.genfromtxt(filename_to_list(outliers)[idx])
        except IOError:
            outlier_val = np.empty((0))
        for index in np.atleast_1d(outlier_val):
            outlier_vector = np.zeros((out_params.shape[0], 1))
            outlier_vector[int(index)] = 1      # ATP 5/26/17
            out_params = np.hstack((out_params, outlier_vector))
        if detrend_poly:
            timepoints = out_params.shape[0]
            X = np.empty((timepoints, 0))
            for i in range(detrend_poly):
                X = np.hstack((X, legendre(
                    i + 1)(np.linspace(-1, 1, timepoints))[:, None]))
            out_params = np.hstack((out_params, X))
        filename = os.path.join(os.getcwd(), "filter_regressor%02d.txt" % idx)
        np.savetxt(filename, out_params, fmt=str("%.10f"))      # ATP 5/26/17
        out_files.append(filename)
    return out_files


def extract_noise_components(realigned_file, mask_file, num_components=5,
                             extra_regressors=None):
    """Derive components most reflective of physiological noise

    Parameters
    ----------
    realigned_file: a 4D Nifti file containing realigned volumes
    mask_file: a 3D Nifti file containing white matter + ventricular masks
    num_components: number of components to use for noise decomposition
    extra_regressors: additional regressors to add

    Returns
    -------
    components_file: a text file containing the noise components
    """
    imgseries = nb.load(realigned_file)
    components = None
    for filename in filename_to_list(mask_file):
        mask = nb.load(filename).get_data()
        if len(np.nonzero(mask > 0)[0]) == 0:
            continue
        voxel_timecourses = imgseries.get_data()[mask > 0]
        voxel_timecourses[np.isnan(np.sum(voxel_timecourses, axis=1)), :] = 0
        # remove mean and normalize by variance
        # voxel_timecourses.shape == [nvoxels, time]
        X = voxel_timecourses.T
        stdX = np.std(X, axis=0)
        stdX[stdX == 0] = 1.
        stdX[np.isnan(stdX)] = 1.
        stdX[np.isinf(stdX)] = 1.
        X = (X - np.mean(X, axis=0)) / stdX
        u, _, _ = sp.linalg.svd(X, full_matrices=False)
        if components is None:
            components = u[:, :num_components]
        else:
            components = np.hstack((components, u[:, :num_components]))
    if extra_regressors:
        regressors = np.genfromtxt(extra_regressors)
        components = np.hstack((components, regressors))
    components_file = os.path.join(os.getcwd(), 'noise_components.txt')
    np.savetxt(components_file, components, fmt=str("%.10f"))   # ATP 5/26/17
    return components_file


def rename(in_files, suffix=None):
    from nipype.utils.filemanip import (filename_to_list, split_filename,
                                        list_to_filename)
    out_files = []
    for idx, filename in enumerate(filename_to_list(in_files)):
        _, name, ext = split_filename(filename)
        if suffix is None:
            out_files.append(name + ('_%03d' % idx) + ext)
        else:
            out_files.append(name + suffix + ext)
    return list_to_filename(out_files)


def get_aparc_aseg(files):
    """Return the aparc+aseg.mgz file"""
    for name in files:
        if 'aparc+aseg.mgz' in name:
            return name
    raise ValueError('aparc+aseg.mgz not found')


def extract_subrois(timeseries_file, label_file, indices):
    """Extract voxel time courses for each subcortical roi index

    Parameters
    ----------

    timeseries_file: a 4D Nifti file
    label_file: a 3D file containing rois in the same space/size of the 4D file
    indices: a list of indices for ROIs to extract.

    Returns
    -------
    out_file: a text file containing time courses for each voxel of each roi
        The first four columns are: freesurfer index, i, j, k positions in the
        label file
    """
    img = nb.load(timeseries_file)
    data = img.get_data()
    roiimg = nb.load(label_file)
    rois = roiimg.get_data()
    prefix = split_filename(timeseries_file)[1]
    out_ts_file = os.path.join(os.getcwd(), '%s_subcortical_ts.txt' % prefix)
    with open(out_ts_file, 'wt') as fp:
        for fsindex in indices:
            ijk = np.nonzero(rois == fsindex)
            ts = data[ijk]
            for i0, row in enumerate(ts):
                fp.write('%d,%d,%d,%d,' % (fsindex, ijk[0][i0],
                                           ijk[1][i0], ijk[2][i0]) +
                         ','.join(['%.10f' % val for val in row]) + '\n')
    return out_ts_file


def combine_hemi(left, right):
    """Combine left and right hemisphere time series into a single text file
    """
    lh_data = nb.load(left).get_data()
    rh_data = nb.load(right).get_data()

    indices = np.vstack((1000000 + np.arange(0, lh_data.shape[0])[:, None],
                         2000000 + np.arange(0, rh_data.shape[0])[:, None]))
    all_data = np.hstack((indices, np.vstack((lh_data.squeeze(),
                                              rh_data.squeeze()))))
    filename = left.split('.')[1] + '_combined.txt'
    np.savetxt(filename, all_data,
               fmt=str(','.join(['%d'] + ['%.10f'] * (all_data.shape[1] - 1)))) # ATP 5/26/17
    return os.path.abspath(filename)


def write_encoding_file(readout, fname, direction):
    import os
    filename = os.path.join(os.getcwd(), 'acq_param_%s.txt' % fname)
    with open(filename, 'w') as f:
        f.writelines(['0 %d 0 %s\n' % (direction, readout),
                      '0 %d 0 %s\n' % (direction * -1, readout)])
    return filename


def create_reg_workflow(name='registration'):
    """Create a FEAT preprocessing workflow together with freesurfer

    Parameters
    ----------

        name : name of workflow (default: 'registration')

    Inputs::

        inputspec.source_files : files (filename or list of filenames to register)
        inputspec.mean_image : reference image to use
        inputspec.anatomical_image : anatomical image to coregister to
        inputspec.target_image : registration target

    Outputs::

        outputspec.func2anat_transform : FLIRT transform
        outputspec.anat2target_transform : FLIRT+FNIRT transform
        outputspec.transformed_files : transformed files in target space
        outputspec.transformed_mean : mean image in target space
    """

    register = Workflow(name=name)

    inputnode = Node(interface=IdentityInterface(fields=['source_files',
                                                         'mean_image',
                                                         'subject_id',
                                                         'subjects_dir',
                                                         'target_image']),
                     name='inputspec')

    outputnode = Node(interface=IdentityInterface(fields=['func2anat_transform',
                                                          'out_reg_file',
                                                          'anat2target_transform',
                                                          'transforms',
                                                          'transformed_mean',
                                                          'segmentation_files',
                                                          'anat2target',
                                                          'aparc',
                                                          'min_cost_file'
                                                          ]),
                      name='outputspec')

    # Get the subject's freesurfer source directory
    fssource = Node(FreeSurferSource(),
                    name='fssource')
    fssource.run_without_submitting = True
    register.connect(inputnode, 'subject_id', fssource, 'subject_id')
    register.connect(inputnode, 'subjects_dir', fssource, 'subjects_dir')

    convert = Node(freesurfer.MRIConvert(out_type='nii'),
                   name="convert")
    #register.connect(fssource, 'T1', convert, 'in_file')
    register.connect(fssource, 'orig', convert, 'in_file')   # ATP 6/16/17 changed due to FAST problem

    ###### ATP 9/16/17

    convert_aseg = Node(freesurfer.MRIConvert(out_type='nii'),
                   name="convert_aseg")
    register.connect(fssource, 'aseg', convert_aseg, 'in_file')

    convert_wmparc = Node(freesurfer.MRIConvert(out_type='nii'),
                   name="convert_wmparc")
    register.connect(fssource, 'wmparc', convert_wmparc, 'in_file')

    merge_masks = Node(Merge(2), iterfield=['in2'], name='merge_masks')
    register.connect(convert_aseg, 'out_file', merge_masks, 'in1')
    register.connect(convert_wmparc, 'out_file', merge_masks, 'in2')

    mask_thresh1 = MapNode(fsl.ImageMaths(),
                          iterfield=['in_file', 'op_string'],
                          name='mask_thresh1')
    mask_thresh1.inputs.op_string = ['-thr 4 -uthr 4', '-thr 5001 -uthr 5002']  # Left-Lateral-Ventricle, left/right wm
    register.connect(merge_masks, 'out', mask_thresh1, 'in_file')

    mask_thresh2 = MapNode(fsl.ImageMaths(),
                          iterfield=['in_file', 'op_string'],
                          name='mask_thresh2')
    mask_thresh2.inputs.op_string = ['-thr 43 -uthr 43', '-thr 3000 -uthr 4999']  # Right-Lateral-Ventricle, left/right wm
    register.connect(merge_masks, 'out', mask_thresh2, 'in_file')

    combine_mask_hemis = MapNode(fsl.ImageMaths(op_string = '-add'),
                          iterfield=['in_file', 'in_file2'],
                          name='combine_mask_hemis')
    register.connect(mask_thresh1, 'out_file', combine_mask_hemis, 'in_file')
    register.connect(mask_thresh2, 'out_file', combine_mask_hemis, 'in_file2')

    ######


    # Coregister the median to the surface
    bbregister = Node(freesurfer.BBRegister(),
                      name='bbregister')
    bbregister.inputs.init = 'fsl'
    bbregister.inputs.contrast_type = 't2'
    bbregister.inputs.out_fsl_file = True
    bbregister.inputs.epi_mask = True
    register.connect(inputnode, 'subject_id', bbregister, 'subject_id')
    register.connect(inputnode, 'mean_image', bbregister, 'source_file')
    register.connect(inputnode, 'subjects_dir', bbregister, 'subjects_dir')

    #"""
    #Estimate the tissue classes from the anatomical image. But use aparc+aseg's brain mask
    #"""

    binarize = Node(fs.Binarize(min=0.5, out_type="nii.gz", dilate=1), name="binarize_aparc")
    register.connect(fssource, ("aparc_aseg", get_aparc_aseg), binarize, "in_file")
    stripper = Node(fsl.ApplyMask(), name='stripper')
    register.connect(binarize, "binary_file", stripper, "mask_file")
    register.connect(convert, 'out_file', stripper, 'in_file')

    # ATP 9/16/17 commenting out, replacing w/ FS outputs
    #fast = Node(fsl.FAST(), name='fast')
    #register.connect(stripper, 'out_file', fast, 'in_files')

    #"""
    #Binarize the segmentation
    #"""

    binarize = MapNode(fsl.ImageMaths(op_string='-nan -thr 0.9 -ero -bin'),
                       iterfield=['in_file'],
                       name='binarize')
    #register.connect(fast, 'partial_volume_files', binarize, 'in_file')
    register.connect(combine_mask_hemis, 'out_file', binarize, 'in_file')

    """
    Apply inverse transform to take segmentations to functional space
    """

    applyxfm = MapNode(freesurfer.ApplyVolTransform(inverse=True,
                                                    interp='nearest'),
                       iterfield=['target_file'],
                       name='inverse_transform')
    register.connect(inputnode, 'subjects_dir', applyxfm, 'subjects_dir')
    register.connect(bbregister, 'out_reg_file', applyxfm, 'reg_file')
    register.connect(binarize, 'out_file', applyxfm, 'target_file')
    register.connect(inputnode, 'mean_image', applyxfm, 'source_file')

    """
    Apply inverse transform to aparc file
    """

    aparcxfm = Node(freesurfer.ApplyVolTransform(inverse=True,
                                                 interp='nearest'),
                    name='aparc_inverse_transform')
    register.connect(inputnode, 'subjects_dir', aparcxfm, 'subjects_dir')
    register.connect(bbregister, 'out_reg_file', aparcxfm, 'reg_file')
    register.connect(fssource, ('aparc_aseg', get_aparc_aseg),
                     aparcxfm, 'target_file')
    register.connect(inputnode, 'mean_image', aparcxfm, 'source_file')

    """
    Convert the BBRegister transformation to ANTS ITK format
    """

    convert2itk = Node(C3dAffineTool(), name='convert2itk')
    convert2itk.inputs.fsl2ras = True
    convert2itk.inputs.itk_transform = True
    register.connect(bbregister, 'out_fsl_file', convert2itk, 'transform_file')
    register.connect(inputnode, 'mean_image', convert2itk, 'source_file')
    register.connect(stripper, 'out_file', convert2itk, 'reference_file')

    """
    Compute registration between the subject's structural and MNI template
    This is currently set to perform a very quick registration. However, the
    registration can be made significantly more accurate for cortical
    structures by increasing the number of iterations
    All parameters are set using the example from:
    #https://github.com/stnava/ANTs/blob/master/Scripts/newAntsExample.sh
    """

    reg = Node(ants.Registration(), name='antsRegister')
    reg.inputs.output_transform_prefix = "output_"
    reg.inputs.transforms = ['Rigid', 'Affine', 'SyN']
    reg.inputs.transform_parameters = [(0.1,), (0.1,), (0.2, 3.0, 0.0)]
    reg.inputs.number_of_iterations = [[10000, 11110, 11110]] * 2 + [[100, 30, 20]]
    reg.inputs.dimension = 3
    reg.inputs.write_composite_transform = True
    reg.inputs.collapse_output_transforms = True
    reg.inputs.initial_moving_transform_com = True
    reg.inputs.metric = ['Mattes'] * 2 + [['Mattes', 'CC']]
    reg.inputs.metric_weight = [1] * 2 + [[0.5, 0.5]]
    reg.inputs.radius_or_number_of_bins = [32] * 2 + [[32, 4]]
    reg.inputs.sampling_strategy = ['Regular'] * 2 + [[None, None]]
    reg.inputs.sampling_percentage = [0.3] * 2 + [[None, None]]
    reg.inputs.convergence_threshold = [1.e-8] * 2 + [-0.01]
    reg.inputs.convergence_window_size = [20] * 2 + [5]
    reg.inputs.smoothing_sigmas = [[4, 2, 1]] * 2 + [[1, 0.5, 0]]
    reg.inputs.sigma_units = ['vox'] * 3
    reg.inputs.shrink_factors = [[3, 2, 1]] * 2 + [[4, 2, 1]]
    reg.inputs.use_estimate_learning_rate_once = [True] * 3
    reg.inputs.use_histogram_matching = [False] * 2 + [True]
    reg.inputs.winsorize_lower_quantile = 0.005
    reg.inputs.winsorize_upper_quantile = 0.995
    reg.inputs.float = True
    reg.inputs.output_warped_image = 'output_warped_image.nii.gz'
    reg.inputs.num_threads = 4
    reg.plugin_args = {'sbatch_args': '-c%d' % 4}
    register.connect(stripper, 'out_file', reg, 'moving_image')
    register.connect(inputnode, 'target_image', reg, 'fixed_image')

    """
    Concatenate the affine and ants transforms into a list
    """

    merge = Node(Merge(2), iterfield=['in2'], name='mergexfm')
    register.connect(convert2itk, 'itk_transform', merge, 'in2')
    register.connect(reg, 'composite_transform', merge, 'in1')

    """
    Transform the mean image. First to anatomical and then to target
    """

    warpmean = Node(ants.ApplyTransforms(), name='warpmean')
    warpmean.inputs.input_image_type = 3
    warpmean.inputs.interpolation = 'Linear'
    warpmean.inputs.invert_transform_flags = [False, False]
    #warpmean.inputs.terminal_output = 'file'  # ATP 11/29/18 commented out
    warpmean.inputs.args = '--float'
    warpmean.inputs.num_threads = 4
    warpmean.plugin_args = {'sbatch_args': '-c%d' % 4}

    register.connect(inputnode, 'target_image', warpmean, 'reference_image')
    register.connect(inputnode, 'mean_image', warpmean, 'input_image')
    register.connect(merge, 'out', warpmean, 'transforms')

    """
    Assign all the output files
    """

    register.connect(reg, 'warped_image', outputnode, 'anat2target')
    register.connect(warpmean, 'output_image', outputnode, 'transformed_mean')
    register.connect(applyxfm, 'transformed_file',
                     outputnode, 'segmentation_files')
    register.connect(aparcxfm, 'transformed_file',
                     outputnode, 'aparc')
    register.connect(bbregister, 'out_fsl_file',
                     outputnode, 'func2anat_transform')
    register.connect(bbregister, 'out_reg_file',
                     outputnode, 'out_reg_file')
    register.connect(reg, 'composite_transform',
                     outputnode, 'anat2target_transform')
    register.connect(merge, 'out', outputnode, 'transforms')
    register.connect(bbregister, 'min_cost_file',
                     outputnode, 'min_cost_file')

    return register


def create_topup_workflow(num_slices, rest_pe_dir, readout,
                          readout_topup, name='topup'):
    """Create a geometric distortion correction workflow using TOPUP

    Parameters
    ----------

    name : name of workflow (default: 'topup')

    Inputs::

        inputspec.realigned_files : realigned resting state time series files
        inputspec.ref_file : reference image to register TOPUP images to realigned files
        inputspec.topup_AP : merged TOPUP images in AP phase-encoding direction
        inputspec.topup_PA : merged TOPUP images in PA phase-encoding direction

    Outputs::

        outputspec.topup_encoding_file : acquisition parameter text file for TOPUP files
        outputspec.rest_encoding_file : acquisition parameter text file for rest file
        outputspec.topup_fieldcoef : spline coefficients encoding the off-resonance field
        outputspec.topup_movpar : TOPUP movement parameters output file
        outputspec.topup_corrected : corrected TOPUP file
        outputspec.applytopup_corrected : corrected resting state time series
    """

    topup = Workflow(name=name)

    inputnode = Node(interface=IdentityInterface(fields=['realigned_files',
                                                         'ref_file',
                                                         'topup_AP',
                                                         'topup_PA',
                                                         ]),
                     name='inputspec')

    outputnode = Node(interface=IdentityInterface(fields=['topup_encoding_file',
                                                          'rest_encoding_file',
                                                          'topup_fieldcoef',
                                                          'topup_movpar',
                                                          'topup_corrected',
                                                          'applytopup_corrected'
                                                          ]),
                      name='outputspec')

    pe_dirs = {'AP':-1, 'PA':1}

    opp_pe_dir = [pe_dir for pe_dir in pe_dirs.keys() if pe_dir != rest_pe_dir][0]

    topup2median = Node(fsl.FLIRT(out_file='%s2median.nii.gz' % rest_pe_dir,
                                  output_type='NIFTI_GZ', interp='spline'),
                        name='%s2median' % rest_pe_dir)
    topup2median.inputs.dof = 6
    topup2median.inputs.out_matrix_file = '%s2median' % rest_pe_dir

    applyxfm = Node(fsl.ApplyXfm(out_file='%s2median.nii.gz' % opp_pe_dir,
                                 apply_xfm=True, interp='spline', output_type='NIFTI_GZ'),
                    name='applyxfm')
    topup.connect(topup2median, 'out_matrix_file', applyxfm, 'in_matrix_file')

    make_topup_list = Node(Merge(2), name='make_topup_list')
    topup.connect(topup2median, 'out_file', make_topup_list, 'in1')
    topup.connect(applyxfm, 'out_file', make_topup_list, 'in2')

    merge_topup = Node(fsl.Merge(dimension='t', output_type='NIFTI_GZ'),
                        name='merge_topup')
    topup.connect(make_topup_list, 'out', merge_topup, 'in_files')

    file_writer_topup = Node(Function(input_names=['readout', 'fname',
                                                   'direction'],
                                output_names=['encoding_file'],
                                function=write_encoding_file),
                       name='file_writer_topup')
    file_writer_topup.inputs.readout = readout_topup
    file_writer_topup.inputs.fname = 'topup'
    file_writer_topup.inputs.direction = pe_dirs[rest_pe_dir]

    run_topup = Node(fsl.TOPUP(out_corrected='b0correct.nii.gz', numprec='float',
                        config='b02b0.cnf', output_type='NIFTI_GZ'),
                    name='run_topup')
    topup.connect(file_writer_topup, 'encoding_file', run_topup, 'encoding_file')

    applytopup = Node(fsl.ApplyTOPUP(output_type='NIFTI_GZ'), name='applytopup')
    applytopup.inputs.in_index = [1]
    applytopup.inputs.method = 'jac'

    file_writer_ts = file_writer_topup.clone(name='file_writer_ts')
    file_writer_ts.inputs.readout = readout
    file_writer_ts.inputs.fname = 'rest_ts'

    topup.connect(merge_topup, 'merged_file', run_topup, 'in_file')
    topup.connect(file_writer_ts, 'encoding_file', applytopup, 'encoding_file')
    topup.connect(run_topup, 'out_fieldcoef', applytopup, 'in_topup_fieldcoef')
    topup.connect(run_topup, 'out_movpar', applytopup, 'in_topup_movpar')

    if num_slices % 2 != 0:

        rm_slice_ts = Node(fsl.ExtractROI(), name='rm_slice_ts')
        rm_slice_ts.inputs.crop_list = [(0,-1), (0,-1), (0, num_slices-1), (0,-1)]

        rm_slice_ref = Node(fsl.ExtractROI(), name='rm_slice_ref')
        rm_slice_ref.inputs.crop_list = [(0,-1),(0,-1),(0, num_slices-1),(0,1)]

        extract_main = rm_slice_ref.clone(name='extract_%s' % rest_pe_dir)

        extract_opp = extract_main.clone(name='extract_%s' % opp_pe_dir)

        topup.connect([(inputnode, rm_slice_ts, [('realigned_files', 'in_file')]),
                     (rm_slice_ts, applytopup, [('roi_file', 'in_files')]),
                     (inputnode, rm_slice_ref, [('ref_file', 'in_file')]),
                     (rm_slice_ref, topup2median, [('roi_file', 'reference')]),
                     (rm_slice_ref, applyxfm, [('roi_file', 'reference')])
                     ])

    else:
        topup.connect([(inputnode, applytopup, [('realigned_files', 'in_files')]),
                     (inputnode, topup2median, [('ref_file', 'reference')]),
                     (inputnode, applyxfm, [('ref_file', 'reference')])])

        extract_main = Node(fsl.ExtractROI(), name='extract_%s' % rest_pe_dir)
        extract_main.inputs.crop_list = [(0,-1), (0,-1), (0,-1), (0,1)]

        extract_opp = extract_main.clone(name='extract_%s' % opp_pe_dir)

    if rest_pe_dir == 'AP':
        topup.connect(inputnode, 'topup_AP', extract_main, 'in_file')
        topup.connect(inputnode, 'topup_PA', extract_opp, 'in_file')
    elif rest_pe_dir == 'PA':
        topup.connect(inputnode, 'topup_PA', extract_main, 'in_file')
        topup.connect(inputnode, 'topup_AP', extract_opp, 'in_file')

    topup.connect(extract_main, 'roi_file', topup2median, 'in_file')
    topup.connect(extract_opp, 'roi_file', applyxfm, 'in_file')

    topup.connect(file_writer_topup, 'encoding_file', outputnode, 'topup_encoding_file')
    topup.connect(file_writer_ts, 'encoding_file', outputnode, 'rest_encoding_file')
    topup.connect(run_topup, 'out_fieldcoef', outputnode, 'topup_fieldcoef')
    topup.connect(run_topup, 'out_movpar', outputnode, 'topup_movpar')
    topup.connect(run_topup, 'out_corrected', outputnode, 'topup_corrected')
    topup.connect(applytopup, 'out_corrected', outputnode, 'applytopup_corrected')

    return topup


"""
Creates the main preprocessing workflow
"""


def create_workflow(files,
                    target_file,
                    subject_id,
                    TR,
                    slice_times,
                    num_slices,
                    norm_threshold=0.5,
                    num_components=5,
                    vol_fwhm=None,
                    surf_fwhm=None,
                    lowpass_freq=-1,
                    highpass_freq=-1,
                    subjects_dir=None,
                    sink_directory=os.getcwd(),
                    target_subject=['fsaverage3', 'fsaverage4'],
                    topup_AP=None,
                    topup_PA=None,
                    rest_pe_dir=None,
                    readout=None,
                    readout_topup=None,
                    name='resting'):

    wf = Workflow(name=name)

    # Rename files in case they are named identically
    name_unique = MapNode(Rename(format_string='rest_%(run)02d'),
                          iterfield=['in_file', 'run'],
                          name='rename')
    name_unique.inputs.keep_ext = True
    name_unique.inputs.run = list(range(1, len(files) + 1))
    name_unique.inputs.in_file = files

    realign = Node(nipy.SpaceTimeRealigner(), name="spacetime_realign")
    realign.inputs.slice_times = slice_times
    realign.inputs.tr = TR
    realign.inputs.slice_info = 2
    realign.plugin_args = {'sbatch_args': '-c%d' % 4}

    # Comute TSNR on realigned data regressing polynomials upto order 2
    tsnr = MapNode(TSNR(regress_poly=2), iterfield=['in_file'], name='tsnr')

    # Compute the median image across runs
    calc_median = Node(Function(input_names=['in_files'],
                                output_names=['median_file'],
                                function=median,
                                imports=imports),
                       name='median')

    if rest_pe_dir == None:
        wf.connect(realign, 'out_file', tsnr, 'in_file')
        wf.connect(tsnr, 'detrended_file', calc_median, 'in_files')


    """Geometric distortion correction using TOPUP
    """

    if rest_pe_dir:
        topup = create_topup_workflow(num_slices, rest_pe_dir, readout,
                                      readout_topup, name='topup')
        topup.inputs.inputspec.topup_AP = topup_AP
        topup.inputs.inputspec.topup_PA = topup_PA

        wf.connect(realign, 'out_file', topup, 'inputspec.realigned_files')
        wf.connect(realign, 'out_file', calc_median, 'in_files')
        wf.connect(calc_median, 'median_file', topup, 'inputspec.ref_file')

        recalc_median = calc_median.clone(name='recalc_median')

        wf.connect(topup, 'outputspec.applytopup_corrected', tsnr, 'in_file')
        wf.connect(tsnr, 'detrended_file', recalc_median, 'in_files')


    """Segment and Register
    """

    registration = create_reg_workflow(name='registration')
    registration.inputs.inputspec.subject_id = subject_id
    registration.inputs.inputspec.subjects_dir = subjects_dir
    registration.inputs.inputspec.target_image = target_file

    if rest_pe_dir == None:
        wf.connect(calc_median, 'median_file', registration, 'inputspec.mean_image')

    if rest_pe_dir:
        wf.connect(recalc_median, 'median_file', registration, 'inputspec.mean_image')

    """Quantify TSNR in each freesurfer ROI
    """

    get_roi_tsnr = MapNode(fs.SegStats(default_color_table=True),
                           iterfield=['in_file'], name='get_aparc_tsnr')
    get_roi_tsnr.inputs.avgwf_txt_file = True
    wf.connect(tsnr, 'tsnr_file', get_roi_tsnr, 'in_file')
    wf.connect(registration, 'outputspec.aparc', get_roi_tsnr, 'segmentation_file')

    """Use :class:`nipype.algorithms.rapidart` to determine which of the
    images in the functional series are outliers based on deviations in
    intensity or movement.
    """

    art = Node(interface=ArtifactDetect(), name="art")
    art.inputs.use_differences = [True, False]
    art.inputs.use_norm = True
    art.inputs.norm_threshold = norm_threshold
    art.inputs.zintensity_threshold = 3
    art.inputs.mask_type = 'spm_global'
    art.inputs.parameter_source = 'NiPy'

    """Here we are connecting all the nodes together. Notice that we add the merge node only if you choose
    to use 4D. Also `get_vox_dims` function is passed along the input volume of normalise to set the optimal
    voxel sizes.
    """

    wf.connect([(name_unique, realign, [('out_file', 'in_file')]),
                (realign, art, [('par_file', 'realignment_parameters')])
                ])

    def selectindex(files, idx):
        import numpy as np
        from nipype.utils.filemanip import filename_to_list, list_to_filename
        return list_to_filename(np.array(filename_to_list(files))[idx].tolist())

    mask = Node(fsl.BET(), name='getmask')
    mask.inputs.mask = True

    # get segmentation in normalized functional space

    if rest_pe_dir == None:
        wf.connect(realign, 'out_file', art, 'realigned_files')
        wf.connect(calc_median, 'median_file', mask, 'in_file')

    if rest_pe_dir:
        wf.connect(topup, 'outputspec.applytopup_corrected', art, 'realigned_files')
        wf.connect(recalc_median, 'median_file', mask, 'in_file')

    def merge_files(in1, in2):
        out_files = filename_to_list(in1)
        out_files.extend(filename_to_list(in2))
        return out_files

    # filter some noise

    # Compute motion regressors
    motreg = Node(Function(input_names=['motion_params', 'order',
                                        'derivatives'],
                           output_names=['out_files'],
                           function=motion_regressors,
                           imports=imports),
                  name='getmotionregress')
    wf.connect(realign, 'par_file', motreg, 'motion_params')

    # Create a filter to remove motion and art confounds
    createfilter1 = Node(Function(input_names=['motion_params', 'comp_norm',
                                               'outliers', 'detrend_poly'],
                                  output_names=['out_files'],
                                  function=build_filter1,
                                  imports=imports),
                         name='makemotionbasedfilter')
    createfilter1.inputs.detrend_poly = 2
    wf.connect(motreg, 'out_files', createfilter1, 'motion_params')
    wf.connect(art, 'norm_files', createfilter1, 'comp_norm')
    wf.connect(art, 'outlier_files', createfilter1, 'outliers')

    filter1 = MapNode(fsl.GLM(out_f_name='F_mcart.nii.gz',
                              out_pf_name='pF_mcart.nii.gz',
                              demean=True),
                      iterfield=['in_file', 'design', 'out_res_name'],
                      name='filtermotion')

    if rest_pe_dir == None:
        wf.connect(realign, 'out_file', filter1, 'in_file')
        wf.connect(realign, ('out_file', rename, '_filtermotart'),
                   filter1, 'out_res_name')

    if rest_pe_dir:
        wf.connect(topup, 'outputspec.applytopup_corrected', filter1, 'in_file')
        wf.connect(topup, ('outputspec.applytopup_corrected', rename, '_filtermotart'),
                   filter1, 'out_res_name')

    wf.connect(createfilter1, 'out_files', filter1, 'design')

    createfilter2 = MapNode(Function(input_names=['realigned_file', 'mask_file',
                                                  'num_components',
                                                  'extra_regressors'],
                                     output_names=['out_files'],
                                     function=extract_noise_components,
                                     imports=imports),
                            iterfield=['realigned_file', 'extra_regressors'],
                            name='makecompcorrfilter')
    createfilter2.inputs.num_components = num_components

    wf.connect(createfilter1, 'out_files', createfilter2, 'extra_regressors')
    wf.connect(filter1, 'out_res', createfilter2, 'realigned_file')
    #wf.connect(registration, ('outputspec.segmentation_files', selectindex, [0, 2]),
    #           createfilter2, 'mask_file')
    wf.connect(registration, ('outputspec.segmentation_files', selectindex, [0, 1]),
               createfilter2, 'mask_file')  # ATP 9/16/17 - FS masks only have 2 outputs, not 3

    filter2 = MapNode(fsl.GLM(out_f_name='F.nii.gz',
                              out_pf_name='pF.nii.gz',
                              demean=True),
                      iterfield=['in_file', 'design', 'out_res_name'],
                      name='filter_noise_nosmooth')
    wf.connect(filter1, 'out_res', filter2, 'in_file')
    wf.connect(filter1, ('out_res', rename, '_cleaned'),
               filter2, 'out_res_name')
    wf.connect(createfilter2, 'out_files', filter2, 'design')
    wf.connect(mask, 'mask_file', filter2, 'mask')

    bandpass = Node(Function(input_names=['files', 'lowpass_freq',
                                          'highpass_freq', 'fs'],
                             output_names=['out_files'],
                             function=bandpass_filter,
                             imports=imports),
                    name='bandpass_unsmooth')
    bandpass.inputs.fs = 1. / TR
    bandpass.inputs.highpass_freq = highpass_freq
    bandpass.inputs.lowpass_freq = lowpass_freq
    wf.connect(filter2, 'out_res', bandpass, 'files')

    """Smooth the functional data using
    :class:`nipype.interfaces.fsl.IsotropicSmooth`.
    """

    smooth = MapNode(interface=fsl.IsotropicSmooth(), name="smooth", iterfield=["in_file"])
    smooth.inputs.fwhm = vol_fwhm

    wf.connect(bandpass, 'out_files', smooth, 'in_file')

    collector = Node(Merge(2), name='collect_streams')
    wf.connect(smooth, 'out_file', collector, 'in1')
    wf.connect(bandpass, 'out_files', collector, 'in2')

    """
    Transform the remaining images. First to anatomical and then to target
    """

    warpall = MapNode(ants.ApplyTransforms(), iterfield=['input_image'],
                      name='warpall')
    warpall.inputs.input_image_type = 3
    warpall.inputs.interpolation = 'Linear'
    warpall.inputs.invert_transform_flags = [False, False]
    #warpall.inputs.terminal_output = 'file'  # ATP 11/29/18 commented out
    warpall.inputs.reference_image = target_file
    warpall.inputs.args = '--float'
    warpall.inputs.num_threads = 2
    warpall.plugin_args = {'sbatch_args': '-c%d' % 2}

    # transform to target
    wf.connect(collector, 'out', warpall, 'input_image')
    wf.connect(registration, 'outputspec.transforms', warpall, 'transforms')

    mask_target = Node(fsl.ImageMaths(op_string='-bin'), name='target_mask')

    wf.connect(registration, 'outputspec.anat2target', mask_target, 'in_file')

    maskts = MapNode(fsl.ApplyMask(), iterfield=['in_file'], name='ts_masker')
    wf.connect(warpall, 'output_image', maskts, 'in_file')
    wf.connect(mask_target, 'out_file', maskts, 'mask_file')

    # map to surface
    # extract aparc+aseg ROIs
    # extract subcortical ROIs
    # extract target space ROIs
    # combine subcortical and cortical rois into a single cifti file

    #######
    # Convert aparc to subject functional space

    # Sample the average time series in aparc ROIs
    sampleaparc = MapNode(freesurfer.SegStats(default_color_table=True),
                          iterfield=['in_file', 'summary_file',
                                     'avgwf_txt_file'],
                          name='aparc_ts')
    sampleaparc.inputs.segment_id = ([8] + list(range(10, 14)) + [17, 18, 26, 47] +
                                     list(range(49, 55)) + [58] + list(range(1001, 1036)) +
                                     list(range(2001, 2036)))

    wf.connect(registration, 'outputspec.aparc',
               sampleaparc, 'segmentation_file')
    wf.connect(collector, 'out', sampleaparc, 'in_file')

    def get_names(files, suffix):
        """Generate appropriate names for output files
        """
        from nipype.utils.filemanip import (split_filename, filename_to_list,
                                            list_to_filename)
        import os
        out_names = []
        for filename in files:
            path, name, _ = split_filename(filename)
            out_names.append(os.path.join(path, name + suffix))
        return list_to_filename(out_names)

    wf.connect(collector, ('out', get_names, '_avgwf.txt'),
               sampleaparc, 'avgwf_txt_file')
    wf.connect(collector, ('out', get_names, '_summary.stats'),
               sampleaparc, 'summary_file')

    # Sample the time series onto the surface of the target surface. Performs
    # sampling into left and right hemisphere
    target = Node(IdentityInterface(fields=['target_subject']), name='target')
    target.iterables = ('target_subject', filename_to_list(target_subject))

    samplerlh = MapNode(freesurfer.SampleToSurface(),
                        iterfield=['source_file'],
                        name='sampler_lh')
    samplerlh.inputs.sampling_method = "average"
    samplerlh.inputs.sampling_range = (0.1, 0.9, 0.1)
    samplerlh.inputs.sampling_units = "frac"
    samplerlh.inputs.interp_method = "trilinear"
    samplerlh.inputs.smooth_surf = surf_fwhm
    # samplerlh.inputs.cortex_mask = True
    samplerlh.inputs.out_type = 'niigz'
    samplerlh.inputs.subjects_dir = subjects_dir

    samplerrh = samplerlh.clone('sampler_rh')

    samplerlh.inputs.hemi = 'lh'
    wf.connect(collector, 'out', samplerlh, 'source_file')
    wf.connect(registration, 'outputspec.out_reg_file', samplerlh, 'reg_file')
    wf.connect(target, 'target_subject', samplerlh, 'target_subject')

    samplerrh.set_input('hemi', 'rh')
    wf.connect(collector, 'out', samplerrh, 'source_file')
    wf.connect(registration, 'outputspec.out_reg_file', samplerrh, 'reg_file')
    wf.connect(target, 'target_subject', samplerrh, 'target_subject')

    # Combine left and right hemisphere to text file
    combiner = MapNode(Function(input_names=['left', 'right'],
                                output_names=['out_file'],
                                function=combine_hemi,
                                imports=imports),
                       iterfield=['left', 'right'],
                       name="combiner")
    wf.connect(samplerlh, 'out_file', combiner, 'left')
    wf.connect(samplerrh, 'out_file', combiner, 'right')

    # Sample the time series file for each subcortical roi
    ts2txt = MapNode(Function(input_names=['timeseries_file', 'label_file',
                                           'indices'],
                              output_names=['out_file'],
                              function=extract_subrois,
                              imports=imports),
                     iterfield=['timeseries_file'],
                     name='getsubcortts')
    ts2txt.inputs.indices = [8] + list(range(10, 14)) + [17, 18, 26, 47] +\
        list(range(49, 55)) + [58]
    ts2txt.inputs.label_file = \
        os.path.abspath(('OASIS-TRT-20_jointfusion_DKT31_CMA_labels_in_MNI152_'
                         '2mm_v2.nii.gz'))
    wf.connect(maskts, 'out_file', ts2txt, 'timeseries_file')

    ######

    substitutions = [('_target_subject_', ''),
                     ('_filtermotart_cleaned_bp_trans_masked', ''),
                     ('_filtermotart_cleaned_bp', ''),
                     ]
    substitutions += [("_smooth%d" % i, "") for i in range(11)[::-1]]
    substitutions += [("_ts_masker%d" % i, "") for i in range(11)[::-1]]
    substitutions += [("_getsubcortts%d" % i, "") for i in range(11)[::-1]]
    substitutions += [("_combiner%d" % i, "") for i in range(11)[::-1]]
    substitutions += [("_filtermotion%d" % i, "") for i in range(11)[::-1]]
    substitutions += [("_filter_noise_nosmooth%d" % i, "") for i in range(11)[::-1]]
    substitutions += [("_makecompcorfilter%d" % i, "") for i in range(11)[::-1]]
    substitutions += [("_get_aparc_tsnr%d/" % i, "run%d_" % (i + 1)) for i in range(11)[::-1]]

    substitutions += [("aseg_out_maths_maths_maths_warped", "fs_compcor_csf"), # ATP 9/16/17 changed due to using FS masks
                      ("wmparc_out_maths_maths_maths_warped", "fs_compcor_wm"),
                      ("orig_out_masked_pve_0_maths_warped", "compcor_csf"), # ATP 6/16/17 changed due to FAST problem
                      ("orig_out_masked_pve_1_maths_warped", "compcor_gm"),
                      ("orig_out_masked_pve_2_maths_warped", "compcor_wm"),
                      #("T1_out_brain_pve_0_maths_warped", "compcor_csf"),
                      #("T1_out_brain_pve_1_maths_warped", "compcor_gm"),
                      #("T1_out_brain_pve_2_maths_warped", "compcor_wm"),
                      ("output_warped_image_maths", "target_brain_mask"),
                      ("median_brain_mask", "native_brain_mask"),
                      ("corr_", "")]

    regex_subs = [('_combiner.*/sar', '/smooth/'),
                  ('_combiner.*/ar', '/unsmooth/'),
                  ('_aparc_ts.*/sar', '/smooth/'),
                  ('_aparc_ts.*/ar', '/unsmooth/'),
                  ('_getsubcortts.*/sar', '/smooth/'),
                  ('_getsubcortts.*/ar', '/unsmooth/'),
                  ('series/sar', 'series/smooth/'),
                  ('series/ar', 'series/unsmooth/'),
                  ('_inverse_transform./', ''),
                  ]
    # Save the relevant data into an output directory
    datasink = Node(interface=DataSink(), name="datasink")
    datasink.inputs.base_directory = sink_directory
    datasink.inputs.container = subject_id
    datasink.inputs.substitutions = substitutions
    datasink.inputs.regexp_substitutions = regex_subs  # (r'(/_.*(\d+/))', r'/run\2')
    wf.connect(realign, 'par_file', datasink, 'resting.qa.motion')
    wf.connect(art, 'norm_files', datasink, 'resting.qa.art.@norm')
    wf.connect(art, 'intensity_files', datasink, 'resting.qa.art.@intensity')
    wf.connect(art, 'outlier_files', datasink, 'resting.qa.art.@outlier_files')
    wf.connect(registration, 'outputspec.segmentation_files', datasink, 'resting.mask_files')
    wf.connect(registration, 'outputspec.anat2target', datasink, 'resting.qa.ants')
    wf.connect(mask, 'mask_file', datasink, 'resting.mask_files.@brainmask')
    wf.connect(mask_target, 'out_file', datasink, 'resting.mask_files.target')
    wf.connect(filter1, 'out_f', datasink, 'resting.qa.compmaps.@mc_F')
    wf.connect(filter1, 'out_pf', datasink, 'resting.qa.compmaps.@mc_pF')
    wf.connect(filter2, 'out_f', datasink, 'resting.qa.compmaps')
    wf.connect(filter2, 'out_pf', datasink, 'resting.qa.compmaps.@p')
    wf.connect(registration, 'outputspec.min_cost_file', datasink, 'resting.qa.mincost')
    wf.connect(tsnr, 'tsnr_file', datasink, 'resting.qa.tsnr.@map')
    wf.connect([(get_roi_tsnr, datasink, [('avgwf_txt_file', 'resting.qa.tsnr'),
                                          ('summary_file', 'resting.qa.tsnr.@summary')])])
    if rest_pe_dir:
        wf.connect(topup, 'outputspec.topup_encoding_file',
                   datasink, 'resting.qa.topup')
        wf.connect(topup, 'outputspec.rest_encoding_file',
                   datasink, 'resting.qa.topup.@acqparam_ts')
        wf.connect(topup, 'outputspec.topup_fieldcoef',
                   datasink, 'resting.qa.topup.@out_fieldcoef')
        wf.connect(topup, 'outputspec.topup_movpar',
                   datasink, 'resting.qa.topup.@out_movpar')
        wf.connect(topup, 'outputspec.topup_corrected',
                   datasink, 'resting.qa.topup.@topup_corrected')
        wf.connect(topup, 'outputspec.applytopup_corrected',
                   datasink, 'resting.qa.topup.@applytopup_corrected')
    wf.connect(bandpass, 'out_files', datasink, 'resting.timeseries.@bandpassed')
    wf.connect(smooth, 'out_file', datasink, 'resting.timeseries.@smoothed')
    wf.connect(createfilter1, 'out_files',
               datasink, 'resting.regress.@regressors')
    wf.connect(createfilter2, 'out_files',
               datasink, 'resting.regress.@compcorr')
    wf.connect(maskts, 'out_file', datasink, 'resting.timeseries.target')
    wf.connect(sampleaparc, 'summary_file',
               datasink, 'resting.parcellations.aparc')
    wf.connect(sampleaparc, 'avgwf_txt_file',
               datasink, 'resting.parcellations.aparc.@avgwf')
    wf.connect(ts2txt, 'out_file',
               datasink, 'resting.parcellations.grayo.@subcortical')
    wf.connect(calc_median, 'median_file', datasink, 'resting')  # ATP 6/16/17

    datasink2 = Node(interface=DataSink(), name="datasink2")
    datasink2.inputs.base_directory = sink_directory
    datasink2.inputs.container = subject_id
    datasink2.inputs.substitutions = substitutions
    datasink2.inputs.regexp_substitutions = regex_subs  # (r'(/_.*(\d+/))', r'/run\2')
    wf.connect(combiner, 'out_file',
               datasink2, 'resting.parcellations.grayo.@surface')
    return wf


"""
Creates the full workflow including getting information from dicom files
"""


def create_resting_workflow(args, name=None):
    TR = args.TR
    slice_times = args.slice_times
    readout = None
    readout_topup = None
    if args.dicom_file:
        TR, slice_times, slice_thickness, bwp, matrix = get_info(args.dicom_file)
        slice_times = (np.array(slice_times) / 1000.).tolist()
        num_slices = len(slice_times)
        echospacing = 1000./(bwp * matrix)
        readout = ((matrix - 1) * echospacing)/1000.

    if args.topup_dicom:
        bwp_topup, matrix_topup = get_info_topup(args.topup_dicom)
        echospacing_topup = 1000./(bwp_topup * matrix_topup)
        readout_topup = ((matrix_topup - 1) * echospacing_topup)/1000.

    if name is None:
        #name = 'resting_' + args.subject_id
        name = args.subject_id  # ATP 6/16/17 changed output dir to just the sub ID
    kwargs = dict(files=[os.path.abspath(filename) for filename in args.files],
                  target_file=os.path.abspath(args.target_file),
                  subject_id=args.subject_id,
                  TR=TR,
                  slice_times=slice_times,
                  num_slices=num_slices,
                  vol_fwhm=args.vol_fwhm,
                  surf_fwhm=args.surf_fwhm,
                  norm_threshold=0.5,
                  subjects_dir=os.path.abspath(args.fsdir),
                  target_subject=args.target_surfs,
                  lowpass_freq=args.lowpass_freq,
                  highpass_freq=args.highpass_freq,
                  sink_directory=os.path.abspath(args.sink),
                  topup_AP=args.topup_AP,
                  topup_PA=args.topup_PA,
                  rest_pe_dir=args.rest_pe_dir,
                  readout=readout,
                  readout_topup=readout_topup,
                  name=name)
    wf = create_workflow(**kwargs)
    return wf

if __name__ == "__main__":
    from argparse import ArgumentParser, RawTextHelpFormatter
    defstr = ' (default %(default)s)'
    parser = ArgumentParser(description=__doc__,
                            formatter_class=RawTextHelpFormatter)
    parser.add_argument("-d", "--dicom_file", dest="dicom_file",
                        help="a SIEMENS example dicom file from the resting series")
    parser.add_argument("-f", "--files", dest="files", nargs="+",
                        help="4d nifti files for resting state",
                        required=True)
    parser.add_argument("-t", "--target", dest="target_file",
                        help=("Target in MNI space. Best to use the MindBoggle "
                              "template - "
                              "OASIS-30_Atropos_template_in_MNI152_2mm.nii.gz"),
                        required=True)
    parser.add_argument("-s", "--subject_id", dest="subject_id",
                        help="FreeSurfer subject id", required=True)
    parser.add_argument("--subjects_dir", dest="fsdir",
                        help="FreeSurfer subject directory", required=True)
    parser.add_argument("--target_surfaces", dest="target_surfs", nargs="+",
                        default=['fsaverage5'],
                        help="FreeSurfer target surfaces" + defstr)
    parser.add_argument("--TR", dest="TR", default=None, type=float,
                        help="TR if dicom not provided in seconds")
    parser.add_argument("--slice_times", dest="slice_times", nargs="+",
                        type=float, help="Slice onset times in seconds")
    parser.add_argument("--topup_dicom", dest="topup_dicom", default=None,
                        help="a SIEMENS example dicom file for topup")
    parser.add_argument("--topup_AP", dest="topup_AP", default=None,
                        help="merged TOPUP images in AP phase-encoding direction")
    parser.add_argument("--topup_PA", dest="topup_PA", default=None,
                        help="merged TOPUP images in PA phase-encoding direction")
    parser.add_argument("--rest_pe_dir", dest="rest_pe_dir", default=None,
                        help="phase-encoding direction of resting nifti: AP or PA")
    parser.add_argument('--vol_fwhm', default=6., dest='vol_fwhm',
                        type=float, help="Spatial FWHM" + defstr)
    parser.add_argument('--surf_fwhm', default=15., dest='surf_fwhm',
                        type=float, help="Spatial FWHM" + defstr)
    parser.add_argument("-l", "--lowpass_freq", dest="lowpass_freq",
                        default=0.1, type=float,
                        help="Low pass frequency (Hz)" + defstr)
    parser.add_argument("-u", "--highpass_freq", dest="highpass_freq",
                        default=0.01, type=float,
                        help="High pass frequency (Hz)" + defstr)
    parser.add_argument("-o", "--output_dir", dest="sink",
                        help="Output directory base", required=True)
    parser.add_argument("-w", "--work_dir", dest="work_dir",
                        help="Output directory base")
    parser.add_argument("-p", "--plugin", dest="plugin",
                        default='Linear',
                        help="Plugin to use")
    parser.add_argument("--plugin_args", dest="plugin_args",
                        help="Plugin arguments")
    args = parser.parse_args()

    wf = create_resting_workflow(args)

    if args.work_dir:
        work_dir = os.path.abspath(args.work_dir)
    else:
        work_dir = os.getcwd()

    wf.base_dir = work_dir

    if (args.topup_dicom and (args.topup_AP is None or args.topup_PA is None or
            args.rest_pe_dir is None)):
        parser.error("topup requires:--topup_dicom,--topup_AP,--topup_PA,--rest_pe_dir")

    if args.plugin_args:
        wf.run(args.plugin, plugin_args=eval(args.plugin_args))
    else:
        wf.run(args.plugin)
