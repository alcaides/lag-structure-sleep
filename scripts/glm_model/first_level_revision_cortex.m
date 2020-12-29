function first_level_revision_cortex()
% =========================================================================
% First level analysis using spm12
% Takes in preprocessed functional files saved after running preprocessing.m
% and events of interest onsets saved after running read_onsetsGLM.m
%
% Syntax:  just first_level
%
% Other m-files required: spm12
% Subfunctions: none
% MAT-files required: dataOnsetsGLM.mat. movements+SCF signal for each
% subject
%
% Authors: Alvaro Romano and Santiago Alcaide
% Laboratorio de Ciencias Cognitivas, Cordoba Argentina
% email: bioing.aromano@gmail.com; santiago_asa@gmail.com
% Website: cognitivas.github.io
% Nov 2018; Last revision: 16-Nov-2018
% =========================================================================

try spm quit; end
display 'start'

% =========================================================================
%                        define paths and variables
% =========================================================================
spm_path            = '/home/pablo/disco/utiles/toolboxes/spm12';

MAIN_DIRECTORY      = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';
dataDirectory       = fullfile(MAIN_DIRECTORY, 'data/Analyze_data');
resultsDirectory    = fullfile(MAIN_DIRECTORY,'results/GLM/first_level_revision_cortex');
batchDirectory      = fullfile(MAIN_DIRECTORY,'scripts/glm_model/first_level_batchs_revision_cortex');
nSubjects           =  3;
j                   =  0;  % indexes number of useful sessions
regexp_func         =  '^swr.*\.nii';

mkdir(resultsDirectory)
mkdir(batchDirectory)

load(fullfile(MAIN_DIRECTORY,'data/dataOnsetsGLM.mat')); %Onsets file, new variable 'dataOnsets'
addpath(batchDirectory)

% =========================================================================
%                           INITIALIZE SPM
% =========================================================================
addpath(spm_path)
spm('defaults', 'FMRI');
spm_jobman('initcfg');

for iSub = 1:nSubjects
    fprintf('Read data for Subject %d\n',iSub);
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
    
    subject_directory   = sprintf('%s/%s%01.0f/', dataDirectory,'subject', iSub);
    
    for iSess = 1:maxSess
        fprintf('Sleep data loading (%d/%d)\n',iSess,maxSess)
        
        funcfiles = cell(1,1);
        
        
        files_directory =  fullfile(MAIN_DIRECTORY,'data/Analyze_data',['subject',num2str(iSub)],...
            ['SleepDataSubject',num2str(iSub),'Session',sprintf('%0.2i', iSess)],...
            ['swImagesSub',sprintf('%0.2i', iSub),'session',sprintf('%0.2i', iSess)]);
        
        
        ffiles  = spm_select('List', files_directory, regexp_func);
        nrun    = size(ffiles,1);
        cffiles = cellstr(ffiles);
        
        for i = 1:nrun
            funcfiles{i,1} = spm_select('ExtFPList', files_directory, ['^', cffiles{i}], Inf);
        end
        
        % =========================================================================
        %                            FIRST_LEVEL_JOB
        % =========================================================================
        matlabbatch{1}.spm.stats.fmri_spec.dir              = {fullfile(resultsDirectory, ['firstlevel_subject_' num2str(iSub), '_session_', sprintf('%02.0f', iSess)])};
        matlabbatch{1}.spm.stats.fmri_spec.timing.units     = 'scans';
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT        = 3;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t    = 50;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0   = 1;
        
        if iSub == 1 && (iSess == 21)
            continue,
        end
        if iSub == 3 && ((iSess == 12) || (iSess == 13))
            continue,
        end
        j = j + 1;  % increments 'subject' counter
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = funcfiles;
        
        % conditions
        % ======================
        
        files_directory =  sprintf('%s/%s%01.0f%s%02.0f/', subject_directory, 'SleepDataSubject', iSub, 'Session', iSess);
        
        % condition 1
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name     = 'WakeUp';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset    = dataOnsets.sub(iSub).sess(iSess).wakingUpOnset;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = 0.6666;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod     = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod     = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth     = 1;
        
        % condition 2
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name     = 'Sleep';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset    = dataOnsets.sub(iSub).sess(iSess).sleepOnset;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = dataOnsets.sub(iSub).sess(iSess).sleepLenght;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod     = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod     = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).orth     = 1;
        
        % condition 3
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).name     = 'Awake';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).onset    = dataOnsets.sub(iSub).sess(iSess).awakeOnset;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).duration = dataOnsets.sub(iSub).sess(iSess).awakeLenght;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).tmod     = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).pmod     = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).orth     = 1;
        
        % condition 4
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).name     = 'Sound';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).onset    = dataOnsets.sub(iSub).sess(iSess).SoundTimes;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).duration = 0.6666;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).tmod     = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).pmod     = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).orth     = 1;
        
        % condition 5
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).name     = 'Response';
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).onset    = dataOnsets.sub(iSub).sess(iSess).RespTimes; 
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).duration = 0.6666;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).tmod     = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).pmod     = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(5).orth     = 1;
%         
        
        % global parameters
        % =====================3
        
        covariateFileName = ['covariates_file_movement_CSF_SleepDataSubject',num2str(iSub),'Session',sprintf('%02d',iSess),'.txt'];
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi            = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress          = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg        = {fullfile(MAIN_DIRECTORY,'data/Movement_files',...
            ['rp_SleepDataSubject',num2str(iSub),'Session',sprintf('%02.0f',iSess),'.txt'])};
            
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf              = 128;
        
        matlabbatch{1}.spm.stats.fmri_spec.fact                     = struct('name', {}, 'levels', {});
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs         = [1 0];
        matlabbatch{1}.spm.stats.fmri_spec.volt                     = 1;
        matlabbatch{1}.spm.stats.fmri_spec.global                   = 'None';
        matlabbatch{1}.spm.stats.fmri_spec.mthresh                  = 0.8;
        matlabbatch{1}.spm.stats.fmri_spec.mask                     = {''};
        matlabbatch{1}.spm.stats.fmri_spec.cvi                      = 'AR(1)';
        
        % estimate and contrasts
        % ======================
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1)                 = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{2}.spm.stats.fmri_est.write_residuals           = 0;
        matlabbatch{2}.spm.stats.fmri_est.method.Classical          = 1;
        
        matlabbatch{3}.spm.stats.con.spmmat(1)                      = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        
        % contrast 1
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name           = 'only wakeUp';
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights        = [1 0   0 0   0 0   0 0   0 0   0 0];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep        = 'sess';
        
        % contrast 2
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name           = 'Sound';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights        = [0 0   0 0   0 0   1 0   0 0   0 0];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep        = 'sess';
        
        % contrast 3
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.name           = 'Awake vs Sound';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights        = [1 0   0 0   0 0   -1 0   0 0   0 0];
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep        = 'sess';
        
        % contrast 4
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.name           = 'Mov';
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights        = [0 0   0 0   0 0   0 0   0 0   1 0];
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep        = 'sess';
        
        % contrast 5
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.name           = 'MovvsSon';
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights        = [0 0   0 0   0 0   0 0   -1 0   1 0];
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep        = 'sess';

        
        matlabbatch{3}.spm.stats.con.delete                         = 0;
        
        
        
        matfile = sprintf('firstlevel_subj%01.0f_sess%02.0f.mat', iSub, iSess);
        save(fullfile(batchDirectory,matfile),'matlabbatch');
        job     = matfile;
        
        spm_jobman('run', job);
    end
end
