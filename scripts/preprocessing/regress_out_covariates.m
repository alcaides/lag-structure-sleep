function regress_out_covariates()
% =========================================================================
% gets SCF and white matter timeseries and regress them out of the data
%
% Syntax:  just regress_out_covariates
%
% Other m-files required: spm12 and rest toolbox
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
addpath /home/pablo/disco/utiles/toolboxes/REST_V1.8_130303/

MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';


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
        directoryIn     = fullfile(MAIN_DIRECTORY,'data','Analyze_data',...
            ['subject',num2str(iSub)],['SleepDataSubject',num2str(iSub),...
            'Session',sprintf('%02d',iSess)],sprintf('./swImagesSub%02.0fsession%02.0f',iSub,iSess));
        
        CovariatesFile  = fullfile(MAIN_DIRECTORY,'scripts/preprocessing/AllCovariatesFiles',['AllCovariates_SleepDataSubject',num2str(iSub),'Session',sprintf('%02d',iSess),'.txt']);
    
        ACovariablesDef.ort_file    = CovariatesFile;
        ACovariablesDef.polort      =1;
        ADataDir                    = directoryIn;
        APostfix                    = 'CovariatesOut';
        AMaskFilename               = fullfile(MAIN_DIRECTORY,...
            'scripts/preprocessing/SCF_ventricles_masks','mascara.img');
        
        rest_RegressOutCovariates(ADataDir,ACovariablesDef,APostfix,AMaskFilename)
    end
end


        
