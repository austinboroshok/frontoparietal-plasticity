% Clear everything
clear;
clc

% Replace with a list of all of the subjects you wish to analyze, using the 
% format below (FILL IN)
subjects = ["subj1" "subj2"]; 

% Run the loop across all subjects
for subject=subjects
    
    subject = char(subject);
    
    % Print which subject is being processed
    fprintf('Processing subject %s:\n', subject)
    
%-----------------------------------------------------------------------
% The script below will apply the MRTool software with the appropriate
% files and settings as per the Ganzetti et al 2014 paper
%-----------------------------------------------------------------------

    % Fill in the directory where you to output all files per subject (FILL
    % IN)
    output_dir = ['/path_to_output_dir/' subject];
    
    % Define the directory where you have downloaded SPM (FILL IN)
    spm_dir = '/Applications/spm12';
    
    % Fill in the subject's specific T1 directory (FILL IN)
    T1_dir = ['/Path_to_subject/' subject '/t1w.nii'];
    
    % Fill in the subject's specific T2 directory (FILL IN)
    T2_dir = ['/Path_to_subject/' subject '/t2w.nii'];
    
    % Subject-specific parameters
    matlabbatch{1}.spm.tools.MRI.MRTool_applic.MRTool_T1T2.res_dir = {output_dir};
    matlabbatch{1}.spm.tools.MRI.MRTool_applic.MRTool_T1T2.t1w = {T1_dir};
    matlabbatch{1}.spm.tools.MRI.MRTool_applic.MRTool_T1T2.t2w = {T2_dir};
    matlabbatch{1}.spm.tools.MRI.MRTool_applic.MRTool_T1T2.t1_template = {[spm_dir '/toolbox/MRTool/template/mni_icbm152_t1_tal_nlin_sym_09a.nii,1']};
    matlabbatch{1}.spm.tools.MRI.MRTool_applic.MRTool_T1T2.t2_template = {[spm_dir '/toolbox/MRTool/template/mni_icbm152_t2_tal_nlin_sym_09a.nii,1']};
    matlabbatch{1}.spm.tools.MRI.MRTool_applic.MRTool_T1T2.tpm_file = {[spm_dir '/toolbox/MRTool/template/TPM.nii,1']};
    
    % Default parameters as per the Ganzetti et al. 2014 paper
    matlabbatch{1}.spm.tools.MRI.MRTool_applic.MRTool_T1T2.biasreg_t1 = 0.0001;
    matlabbatch{1}.spm.tools.MRI.MRTool_applic.MRTool_T1T2.biasfwhm_t1 = 60;
    matlabbatch{1}.spm.tools.MRI.MRTool_applic.MRTool_T1T2.biasreg_t2 = 0.0001;
    matlabbatch{1}.spm.tools.MRI.MRTool_applic.MRTool_T1T2.biasfwhm_t2 = 60;
    matlabbatch{1}.spm.tools.MRI.MRTool_applic.MRTool_T1T2.structural_res = 1;
    matlabbatch{1}.spm.tools.MRI.MRTool_applic.MRTool_T1T2.calibration_flag = 1;
    
    % Run the actual script per subject
    spm('defaults', 'FMRI');
    spm_jobman('run', matlabbatch);
end

