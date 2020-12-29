function preprocessing()
% =========================================================================
% Preprocessing for spm12
% Authors: Alvaro Romano and Santiago Alcaide
% Laboratorio de Ciencias Cognitivas, Cordoba Argentina
% email: bioing.aromano@gmail.com; santiago_asa@gmail.com
% Website: cognitivas.github.io
% Nov 2018; Last revision: 08-Nov-2018
% =========================================================================

try spm quit; end
display 'start'

% =========================================================================
%                        LOCATE THE DATA TO BE USED
% =========================================================================
spm_path = '/home/pablo/disco/utiles/toolboxes/spm12';

addpath(spm_path)
MAIN_DIRECTORY = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';

cd (fullfile(MAIN_DIRECTORY,'data', 'Analyze_data'));

regexp_func    = '^*\.nii';
regexp_anat    = '.img';

% =========================================================================
%                         PREPROCESSING PARAMETERS
% =========================================================================

smoothing_kernel        = [5 5 5];
TR                      = 3.0;
nslices                 = 50;
TA                      = TR * (1-1/nslices);
nSubj                   = 3;
refslice                = 24;
slice_order             = [2:2:50,1:2:49];
voxel_size              = [3 3 3];
% =========================================================================
%                           INITIALIZE SPM
% =========================================================================

spm('defaults', 'FMRI');
spm_jobman('initcfg');


% =========================================================================
%                            GET DATA FILES
% =========================================================================

subjectsXsession = 0; % counter for subjects x session

for iSub = 1:nSubj
    fprintf('\n');
    fprintf('Read data for Subject %d\n',iSub);

    subjdir = fullfile(MAIN_DIRECTORY, 'data','Analyze_data',['subject', num2str(iSub)]);

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
    
    funcfiles = cell(1,1);
    for iSess = 1:maxSess
        disp(' ')
        fprintf('Sleep data loading (%d/%d)\n',iSess,maxSess)
        
        subjectsXsession = subjectsXsession + 1;  % one session is considered one independent subject
        
        anatdir     =  fullfile(subjdir,['SleepDataSubject', num2str(iSub), 'Session', sprintf('%02.0f',iSess)],'struct');
        exp_anat    = sprintf('T1_Subject%01.0d%s',iSub,regexp_anat);
        anatfile    = spm_select('FPList', anatdir, exp_anat);

        if isequal(anatfile,  '') || not(exist(anatfile))
            error('No T1 file')
        end
        
        fdir    =  fullfile(subjdir, ['SleepDataSubject', num2str(iSub), 'Session', sprintf('%02.0f',iSess)]);
        ffiles  = spm_select('List', fdir, regexp_func);
        nFiles    = size(ffiles,1);
        
        if nFiles == 0
            error('No functional file')
        end
        cffiles = cellstr(ffiles);
        
        for iFiles = 1:nFiles
            funcfiles{iFiles,1} = spm_select('ExtFPList', fdir, ['^', cffiles{iFiles}], Inf);
        end
        
        
        clear matlabbatch
        
        % =========================================================================
        %                            PREPROCESS_JOB
        % =========================================================================
        
        display 'Creating preprocessing job'
        
        % Realign
        % ======================
        
        matlabbatch{1}.spm.spatial.realign.estimate.data        = {funcfiles};
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.quality    = 0.9;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.sep        = 4;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.fwhm       = 5;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.rtm        = 1;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.interp     = 2;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.wrap       = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions.weight     = '';
        
        matlabbatch{2}.spm.spatial.realign.write.data(1)                = cfg_dep('Realign: Estimate: Realigned Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','cfiles'));
        matlabbatch{2}.spm.spatial.realign.write.roptions.which         = [2 1];
        matlabbatch{2}.spm.spatial.realign.write.roptions.interp        = 4;
        matlabbatch{2}.spm.spatial.realign.write.roptions.wrap          = [0 0 0];
        matlabbatch{2}.spm.spatial.realign.write.roptions.mask          = 1;
        matlabbatch{2}.spm.spatial.realign.write.roptions.prefix        = 'r';
        
        
        %Coregister
        % ======================
        display 'Coregister'
        matlabbatch{3}.spm.spatial.coreg.estimate.ref(1)                = cfg_dep('Realign: Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
        matlabbatch{3}.spm.spatial.coreg.estimate.source                = {[anatfile,',1']};
        matlabbatch{3}.spm.spatial.coreg.estimate.other                 = {''};
        matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun     = 'nmi';
        matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep          = [4 2];
        matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol          = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm         = [7 7];
        
        matlabbatch{4}.spm.spatial.preproc.channel.vols                 = {[anatfile,',1']};
        matlabbatch{4}.spm.spatial.preproc.channel.biasreg              = 0.001;
        matlabbatch{4}.spm.spatial.preproc.channel.biasfwhm             = 60;
        matlabbatch{4}.spm.spatial.preproc.channel.write                = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(1).tpm                = {sprintf('%s/tpm/TPM.nii,1', spm_path)};
        matlabbatch{4}.spm.spatial.preproc.tissue(1).ngaus              = 1;
        matlabbatch{4}.spm.spatial.preproc.tissue(1).native             = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(1).warped             = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(2).tpm                = {sprintf('%s/tpm/TPM.nii,2', spm_path)};
        matlabbatch{4}.spm.spatial.preproc.tissue(2).ngaus              = 1;
        matlabbatch{4}.spm.spatial.preproc.tissue(2).native             = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(2).warped             = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(3).tpm                = {sprintf('%s/tpm/TPM.nii,3', spm_path)};
        matlabbatch{4}.spm.spatial.preproc.tissue(3).ngaus              = 2;
        matlabbatch{4}.spm.spatial.preproc.tissue(3).native             = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(3).warped             = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(4).tpm                = {sprintf('%s/tpm/TPM.nii,4', spm_path)};
        matlabbatch{4}.spm.spatial.preproc.tissue(4).ngaus              = 3;
        matlabbatch{4}.spm.spatial.preproc.tissue(4).native             = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(4).warped             = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(5).tpm                = {sprintf('%s/tpm/TPM.nii,5', spm_path)};
        matlabbatch{4}.spm.spatial.preproc.tissue(5).ngaus              = 4;
        matlabbatch{4}.spm.spatial.preproc.tissue(5).native             = [1 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(5).warped             = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(6).tpm                = {sprintf('%s/tpm/TPM.nii,6', spm_path)};
        matlabbatch{4}.spm.spatial.preproc.tissue(6).ngaus              = 2;
        matlabbatch{4}.spm.spatial.preproc.tissue(6).native             = [0 0];
        matlabbatch{4}.spm.spatial.preproc.tissue(6).warped             = [0 0];
        matlabbatch{4}.spm.spatial.preproc.warp.mrf                     = 1;
        matlabbatch{4}.spm.spatial.preproc.warp.cleanup                 = 1;
        matlabbatch{4}.spm.spatial.preproc.warp.reg                     = [0 0.001 0.5 0.05 0.2];
        matlabbatch{4}.spm.spatial.preproc.warp.affreg                  = 'mni';
        matlabbatch{4}.spm.spatial.preproc.warp.fwhm                    = 0;
        matlabbatch{4}.spm.spatial.preproc.warp.samp                    = 3;
        matlabbatch{4}.spm.spatial.preproc.warp.write                   = [0 0];
        
        % Normalise
        % ======================
        display 'Spatial normalise'
        matlabbatch{5}.spm.spatial.normalise.estwrite.subj.vol(1)       = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
        matlabbatch{5}.spm.spatial.normalise.estwrite.subj.resample(1)  = cfg_dep('Realign: Reslice: Resliced Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
        matlabbatch{5}.spm.spatial.normalise.estwrite.eoptions.biasreg  = 0.0001;
        matlabbatch{5}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
        matlabbatch{5}.spm.spatial.normalise.estwrite.eoptions.tpm      = {sprintf('%s/tpm/TPM.nii', spm_path)};
        matlabbatch{5}.spm.spatial.normalise.estwrite.eoptions.affreg   = 'mni';
        matlabbatch{5}.spm.spatial.normalise.estwrite.eoptions.reg      = [0 0.001 0.5 0.05 0.2];
        matlabbatch{5}.spm.spatial.normalise.estwrite.eoptions.fwhm     = 0;
        matlabbatch{5}.spm.spatial.normalise.estwrite.eoptions.samp     = 3;
        matlabbatch{5}.spm.spatial.normalise.estwrite.woptions.bb       = [-78 -112 -70
            78 76 85];
        matlabbatch{5}.spm.spatial.normalise.estwrite.woptions.vox      = voxel_size;
        matlabbatch{5}.spm.spatial.normalise.estwrite.woptions.interp   = 4;
        matlabbatch{5}.spm.spatial.normalise.estwrite.woptions.prefix   = 'w';
        
        % Smooth
        % ======================
        display 'Spatial smooth'
        matlabbatch{6}.spm.spatial.smooth.data(1)                       = cfg_dep('Normalise: Estimate & Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{6}.spm.spatial.smooth.fwhm                          = smoothing_kernel;
        matlabbatch{6}.spm.spatial.smooth.dtype                         = 0;
        matlabbatch{6}.spm.spatial.smooth.im                            = 0;
        matlabbatch{6}.spm.spatial.smooth.prefix                        = 's';
        
               
        % ======================        
        matfile                 = sprintf('%s/%s/preprocess_subj%02.0f.mat',MAIN_DIRECTORY,'scripts/preprocessing/preprocessing_batchs', subjectsXsession);
        save(matfile,'matlabbatch');
        jobs{subjectsXsession}  = matfile;
    end   
end
spm_jobman('run', jobs);


