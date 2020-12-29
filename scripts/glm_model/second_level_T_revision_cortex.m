function second_level_T_revision_cortex()
% =========================================================================
% second level analysis.

% Syntax:  just second_level_T
%
% Other m-files required: spm12
% Subfunctions: none
% files required: first level for every session (first_level.m file)
%
% Authors: Alvaro Romano and Santiago Alcaide
% Laboratorio de Ciencias Cognitivas, Cordoba Argentina
% email: bioing.aromano@gmail.com; santiago_asa@gmail.com
% Website: cognitivas.github.io
% Nov 2018; Last revision: 16-Nov-2018
% =========================================================================

clc,
spm_path            = '/home/pablo/disco/utiles/toolboxes/spm12';

MAIN_DIRECTORY      = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';
dataDirectory       = fullfile(MAIN_DIRECTORY,'results/GLM/first_level_revision_cortex');


iSubject = 3;

confiles = cell(1,1);


contrastsNames = {...
    'only_wakeUp';
    'Sound';
    'Awake_vs_Sound';
    'Mov';
    'MovvsSon';    
   };

nContrasts =  size(contrastsNames,1);

addpath(spm_path)

spm('defaults', 'FMRI');
spm_jobman('initcfg');

for iContrast = 1:nContrasts;
    j = 0;
    
    for iSub = iSubject
        
        resultsDirectory    = fullfile(MAIN_DIRECTORY,'results/GLM/second_level_batchs_revision_cortex',['subject',num2str(iSub)]);
        batchDirectory      = fullfile(MAIN_DIRECTORY,'scripts/glm_model/second_level_batchs_revision_cortex',['subject',num2str(iSub)]);
        if not(exist(resultsDirectory)),mkdir(resultsDirectory),end
        if not(exist(batchDirectory)),mkdir(batchDirectory),end
        

        
        
        
        switch iSub
            case 1
                maxSess = 26;
            case 2
                maxSess = 14;
            case 3
                maxSess = 15;
            otherwise
                error('incorrect subject number');
        end
        
        for iSess = 1:maxSess
            sessionDirectory =  sprintf('%s/%s%01.0f%s%02.0f', dataDirectory, 'firstlevel_subject_', iSub, '_session_', iSess);
            
            if exist(sessionDirectory,'dir')
                j               = j + 1;
                regexp_con      = sprintf('%s%02.0f%s', 'con_00', iContrast, '.nii');
                cfiles          = spm_select('FPList', sessionDirectory, regexp_con);
                confiles {j,1}  = cfiles;
                cvar(j,1)       = 1; 
            end
        end
    end
    
    
    matlabbatch{1}.spm.stats.factorial_design.dir                       = {fullfile(resultsDirectory, [ sprintf('contrast_%02.0f',iContrast) ,'_', contrastsNames{iContrast}])};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans              = confiles;
    matlabbatch{1}.spm.stats.factorial_design.multi_cov(1).files        = {};
    matlabbatch{1}.spm.stats.factorial_design.multi_cov(1).iCFI         = 1;
    matlabbatch{1}.spm.stats.factorial_design.multi_cov(1).iCC          = 5;
    
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none        = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im                = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em                = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit            = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no    = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm           = 1;
    
    
    % estimate and contrast
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1)                         = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals                   = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical                  = 1;
    
    %contrast
    matlabbatch{3}.spm.stats.con.spmmat(1)                              = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name                   = contrastsNames{iContrast};
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights                = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep                = 'sess';
    matlabbatch{3}.spm.stats.con.delete = 0;
    %
    matfile = ['contrast_', sprintf('%02.0f',iContrast),'_',contrastsNames{iContrast},'.mat'];
    matfile = fullfile(batchDirectory,matfile);
    
    save(matfile,'matlabbatch');
    jobs{iContrast} = matfile;
end
spm_jobman('run', jobs);
