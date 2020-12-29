function get_SCF_WM_signal()
% =========================================================================
% gets SCF and white matter signal from sw images to regress out
%
% Syntax:  just get_SCF_WM_signal
%
% Other m-files required: spm12
% Subfunctions: none
% MAT-files required: none
% subject
%
% Authors: Alvaro Romano and Santiago Alcaide
% Laboratorio de Ciencias Cognitivas, Cordoba Argentina
% email: bioing.aromano@gmail.com; santiago_asa@gmail.com
% Website: cognitivas.github.io
% Nov 2018; Last revision: 16-Nov-2018
% =========================================================================
clc

spm_path = '/home/pablo/disco/utiles/toolboxes/spm12';
addpath(spm_path)

MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';
masksDirectory  = fullfile(MAIN_DIRECTORY, 'scripts/preprocessing/SCF_ventricles_masks');

directoryOut = fullfile(MAIN_DIRECTORY,'scripts/preprocessing/AllCovariatesFiles');

header              = spm_vol(fullfile(masksDirectory,'rleft_ventricle.nii'));
VI                  = spm_read_vols(header);             
maskLeftVentricle   = logical(VI);

header              = spm_vol(fullfile(masksDirectory,'rright_ventricle.nii'));
VD                  = spm_read_vols(header);   
maskRightVentricle  = logical(VD);


header              = spm_vol(fullfile(masksDirectory,'rwm_left.nii'));
WMI                 = spm_read_vols(header);   
maskLeftWhiteMatter = logical(WMI);

header              = spm_vol(fullfile(masksDirectory,'rwm_right.nii'));
WMD                 = spm_read_vols(header);   
maskRightWhiteMatter= logical(WMD);



nSubjects = 3;

for iSub = 1:nSubjects

    fprintf('Read data for Subject %d\n',iSub);
    switch iSub
        case 1
            nSleepDataSession = 26;
        case 2
            nSleepDataSession = 14;
        case 3
            nSleepDataSession = 15;
        otherwise
            error('incorrect subject number');
    end
    
    for iSess = 1:nSleepDataSession
        fprintf('Sleep data loading(%d/%d)\n',iSess,nSleepDataSession)
         
        directoryIn = fullfile(MAIN_DIRECTORY,'data','Analyze_data',['subject',num2str(iSub)],['SleepDataSubject',num2str(iSub),'Session',sprintf('%02d',iSess)],...
            ['swImagesSub',sprintf('%0.2i', iSub),'session',sprintf('%0.2i', iSess)]);
        cd(directoryIn)
        ims = dir('s*.nii');
        
        Files=spm_select('list',pwd,'^sw.*\.nii$');

        LeftVent     = []; 
        RightVent    = [];
        LeftWhiteM   = []; 
        RightWhiteM  = [];
        
        for iImage = 1:size(Files,1)            
            im              = spm_vol(Files(iImage,:));
            scan            = spm_read_vols(im);
            
            LeftVent        = [LeftVent,     mean(scan(maskLeftVentricle))];
            RightVent       = [RightVent,    mean(scan(maskRightVentricle))];
            
            LeftWhiteM      = [LeftWhiteM,   mean(scan(maskLeftWhiteMatter))];
            RightWhiteM     = [RightWhiteM,  mean(scan(maskRightWhiteMatter))];
        end
        
        MovementTimeSeries = load(fullfile(MAIN_DIRECTORY,'/data/Movement_files',['rp_SleepDataSubject', num2str(iSub),'Session',sprintf('%02d',iSess),'.txt']));

        AllCovariates       = [LeftVent' RightVent' LeftWhiteM' RightWhiteM' MovementTimeSeries];
        
        cd(directoryOut)
        
        save(['AllCovariates_SleepDataSubject',num2str(iSub),'Session',sprintf('%02d',iSess),'.txt'],'AllCovariates', '-ascii')
    end
end
