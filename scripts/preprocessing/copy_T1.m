function copy_T1()
% =========================================================================
% copy_T1.m - copies T1 files for each subject into session folder

% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Authors: Alvaro Romano and Santiago Alcaide
% Laboratorio de Ciencias Cognitivas, Cordoba Argentina
% email: bioing.aromano@gmail.com; santiago_asa@gmail.com
% Website: cognitivas.github.io
% Nov 2018; Last revision: 08-Nov-2018
% =========================================================================

MAIN_DIRECTORY = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';

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
        fprintf('Sleep data loading (%d/%d)\n',iSess,nSleepDataSession)
        
        directoryIn = fullfile(MAIN_DIRECTORY,'data/Analyze_data',['subject',num2str(iSub)],...
            ['SleepDataSubject',num2str(iSub),'Session',sprintf('%0.2i', iSess)]);
        
        cd(directoryIn)
        mkdir('struct')
        cd('struct')
        
        t1Img = fullfile(MAIN_DIRECTORY,'data/T1andSpaceDefine',['T1_Subject' num2str(iSub),'.img']);
        t1Hdr = fullfile(MAIN_DIRECTORY,'data/T1andSpaceDefine',['T1_Subject' num2str(iSub),'.hdr']);
        
        copyfile(t1Img,'.')
        copyfile(t1Hdr,'.')
    end
end