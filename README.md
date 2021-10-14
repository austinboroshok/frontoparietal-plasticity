# frontoparietal-plasticity
Individual differences in frontoparietal plasticity in humans (Boroshok et al., under review). Please see below for relevant data files and code for analysis. Please contact the authors (Austin Boroshok, boroshok@sas.upenn.edu; Allyson Mackey,mackeya@upenn.edu) with further questions or data requests.

Description of files within this repository:

The top-level directory "Materials for manuscript Individual differences in frontoparietal plasticity in humans" contains all behavioral and extracted neuroimaging data as well as all neccesary code to replicate the reported results. Neuroimaging data can be found on openneuro.org at _________.



    'plasticity_mri_sample.csv' contains all imaging and behavioral data collected during this study and used for analysis.

    'data_dictionary.xslx' provides a desription of each variable within the master dataset ('plasticity_mri_sample.csv').

    'plasticity.Rmd' contains the R code used to run all analyses create Results section of manuscript.


Imagine Processing Pipeline ('analysis code' subdirectory:
Within the 'analysis code' subdirectory, we uploaded three folders ('Myelin Mapping,' 'Resting State,' and 'Task/FEAT') that contain all scripts used to process participants' MRI data. Below we have listed a description of all files within each of these folders:


**Myelin Mapping (files are listed in sequential order of analysis):**

    1. **'Ganzetti et al. (2014) code'** is a folder containing the **'MRTool'** package needing to generate the 'myelin map' T1/T2 ratio images. All code within this folder was provided by Ganzetti and colleagues at https://www.nitrc.org/projects/mrtool/. Dr. Marco Ganzetti can be contacted at marco.ganzetti@kuleuven.be. Prior to running subsequent analyses, MRTool subdirectory should be copied into **'SPM12/tools'** wherever you have **SPM12** stored.
    
    2. **'submit_T1_T2_ratio.job.sh'** is a Bash script that runs the **'T1_T2_ratio_job.m'** MATLAB file from the command line. The **'T1_T2_ratio_job.m'** MATLAB file creates the T1/T2 ratio images, or "myelin maps." At the very end of this MATLAB file, you can specify which calibration method you wish to use (see **'Ganzetti et al. (2014) code/T1-wT2-w image.pdf'** for a list of options).
    
    3. The myelin map images created by the MRTool package are reported to be in native space but have actually only been centered and rotated to be in alignment with the MNI template even though they are still within the general native subject space. Thus, they are in perfect overlap with the MNI brain but are not in true T1 space. To address this, next run the **'register_mm_to_subject_space.sh'** script to linearly register the output ratio file to the actual raw T1 subject space before extracting values.
    
    4. Next, run the **'create_mm_aparc_mask_transform_roi.sh'** script. This will mask out cerebrospinal fluid (CSF), corpus callosum (CC), and white matter from your myelin map images to ensure you are extracting myelin map values from gray matter. There is optional code at the end of this script to inverse-transform ROIs from which you will be extracting myelin map values into subject space. If you wish to extract MM values from ROIs derived from tasks data that are in MNI space, you will need to move these ROis into subject space first.
    
    5. Finally, run the **mm_extract.sh'** to extract the median intensity of a particular ROI from your myelin map images.
    
    
       

Resting State:



Task/FEAT:



Please contact the authors (Austin Boroshok, boroshok@sas.upenn.edu; Allyson Mackey,mackeya@upenn.edu) with further questions or data requests.
