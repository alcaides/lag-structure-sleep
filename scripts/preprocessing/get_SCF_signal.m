function get_SCF_signal()
% =========================================================================
% SCF signal to be extracted on smoothed data.
% Generates a txt file for every session with the individual SCF signal
% and movements in the same file, using pre-made sphere masks of left and
% right ventricles.
%
% Syntax: get_SCF_signal
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Authors: Alvaro Romano and Santiago Alcaide
% Laboratorio de Ciencias Cognitivas, Cordoba Argentina
% email: bioing.aromano@gmail.com; santiago_asa@gmail.com
% Website: cognitivas.github.io
% Nov 2018; Last revision: 16-Nov-2018
% =========================================================================
clc
addpath /home/pablo/disco/utiles/toolboxes/spm12/

MAIN_DIRECTORY ='/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';


header  = spm_vol(fullfile(MAIN_DIRECTORY,'scripts/preprocessing/SCF_ventricles_masks/rleft_ventricle.nii'));
LV      = spm_read_vols(header);
mask_LV = logical(LV);

header  = spm_vol(fullfile(MAIN_DIRECTORY,'scripts/preprocessing/SCF_ventricles_masks/rright_ventricle.nii'));
RV      = spm_read_vols(header);
mask_RV = logical(RV);


nSubjects = 3;

for iSub = 1:nSubjects
    
    fprintf('Read data for Subject %d\n',iSub);
    switch iSub
        case 1
            maxSess=26;
        case 2
            maxSess=14;
        case 3
            maxSess=15;
        otherwise
            error('incorrect subject number');
    end
    
    for iSess = 1:maxSess
        fprintf('Sleep data loading(%d/%d)\n',iSess,maxSess)
        
        
        subjectsDirectory = fullfile(MAIN_DIRECTORY,'data/Analyze_data',['subject',num2str(iSub)],...
            ['SleepDataSubject',num2str(iSub),'Session',sprintf('%0.2i', iSess)],...
            ['swImagesSub',sprintf('%0.2i', iSub),'session',sprintf('%0.2i', iSess)]);

        cd(subjectsDirectory)
        
        ims = dir('sw*.nii');
        
        Files = spm_select('list',pwd,'^swra.*\.nii$');
        
        LeftVentTs       = [];  % time series for left/right ventricles/white matter
        RightVentTs      = [];
        
        for iImage = 1:size(Files,1)
            oneImageHeader = spm_vol(Files(iImage,:));
            oneImage       = spm_read_vols(oneImageHeader);
            
            LeftVentTs     = [LeftVentTs,    mean(oneImage(mask_LV))];
            RightVentTs    = [RightVentTs,   mean(oneImage(mask_RV))];
        end
        
        
        movementFile = fullfile(MAIN_DIRECTORY,'/data/Movement_files',['rp_SleepDataSubject', num2str(iSub),'Session',sprintf('%02d',iSess),'.txt']);
        movementData = load(movementFile);
        
        allCovariates = [LeftVentTs' RightVentTs' movementData];
        
        cd(subjectsDirectory)
        fileName = ['covariates_file_movement_CSF_SleepDataSubject',num2str(iSub),'Session',sprintf('%02d',iSess),'.txt'];
        save(fileName,'allCovariates', '-ascii')
    end
end
end

