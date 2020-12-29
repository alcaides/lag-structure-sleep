function h52nii()
% =========================================================================
%h52nii.m - reads h5 files and saves 3D nii data files
% Syntax:  just h52nii
%
% Other m-files required: func_h5 library
% Subfunctions: none
% MAT-files required: none
%
% Authors: Alvaro Romano and Santiago Alcaide
% Laboratorio de Ciencias Cognitivas, Cordoba Argentina
% email: bioing.aromano@gmail.com; santiago_asa@gmail.com
% Website: cognitivas.github.io
% Nov 2018; Last revision: 08-Nov-2018
% =========================================================================
clc
MAIN_DIRECTORY = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';

addpath(fullfile(MAIN_DIRECTORY,'scripts/func_h5'))  % adds h5 functions
addpath /home/pablo/disco/utiles/toolboxes/spm12/

nSubjects = 3;


for iSub = 1:nSubjects
    
    fprintf('Read data for Subject %d\n',iSub);
    
    % reads a header to define space
    header = spm_vol(fullfile(MAIN_DIRECTORY,'data/T1andSpaceDefine',...
        ['spaceDefine_Subject',num2str(iSub),'.img']));
    
    
    switch iSub    % defines session number for each subject
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
        fprintf('Sleep data loading (%d/%d)\n',iSess,nSleepDataSession)
        
        
        file = fullfile(MAIN_DIRECTORY,'data/OriginalSleeph5',...
            ['SleepDataSubject',num2str(iSub),'Session',num2str(iSess)]);
        
        dataH5 = readHDF5AsStruct(file);
        data   = dataH5.group1.data;   % reads the data
        
        directoryOut = ['SleepDataSubject',num2str(iSub),'Session',...
            sprintf('%02d',iSess)];
        
        directoryOut = fullfile(MAIN_DIRECTORY,'data/Analyze_data',...
            ['subject',num2str(iSub)],directoryOut);
        
        mkdir(directoryOut)
        cd(directoryOut)
        
        for iImage = 1:size(data,1)     % saves data in 3D nii format
            oneImage = squeeze(data(iImage,:,:,:));
            
            header.fname = ['SleepDataSubject',num2str(iSub),'Session',...
                num2str(iSess) '_' sprintf('%04d',iImage),'.nii'];
            
            spm_write_vol(header,oneImage);
        end
    end
end
