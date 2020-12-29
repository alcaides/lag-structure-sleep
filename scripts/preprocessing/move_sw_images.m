function move_sw_images()
% =========================================================================
% moves sw images to a folder created inside the session folder.
%
% Syntax:  move_sw_images
%
% Other m-files required: none
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
            error('incorrect subject number');       cd(directoryIn)
    end
    
    for iSess = 1:nSleepDataSession
        fprintf('Sleep data loading(%d/%d)\n',iSess,nSleepDataSession)
        directoryIn     = fullfile(MAIN_DIRECTORY,'data','Analyze_data',['subject',num2str(iSub)],['SleepDataSubject',num2str(iSub),'Session',sprintf('%02d',iSess)]);
        cd(directoryIn)
        mkdir(sprintf('swImagesSub%02.0fsession%02.0f',iSub,iSess))
        movefile('swr*',sprintf('./swImagesSub%02.0fsession%02.0f',iSub,iSess))
%         !rm -r *CovariatesOut/
    end
end
