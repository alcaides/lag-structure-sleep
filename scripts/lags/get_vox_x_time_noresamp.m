function get_vox_x_time_noresamp()
% =========================================================================
% get_vox_x_time_noresamp - reads data and get vox x time files for each
% component
% Syntax: get_vox_x_time_noresamp

% Other m-files required: none
% Subfunctions: none
% MAT-files required: onsets file
%
% Authors: Alvaro Romano and Santiago Alcaide
% Laboratorio de Ciencias Cognitivas, Cordoba Argentina
% email: alvaroromano13@gmail.com; santiago_asa@gmail.com
% Website: cognitivas.github.io
% Oct 2018; Last revision: 30-Oct-2018
% =========================================================================

clc

component = 'firstcomponent'; % first/secondcomponent;
% component = 'secondcomponent'; % first/secondcomponent;


addpath /home/pablo/disco/utiles/toolboxes/spm12/

MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';

load(fullfile(MAIN_DIRECTORY,'data/dataOnsets_lags.mat'));

header  = spm_vol(fullfile(MAIN_DIRECTORY,'scripts/preprocessing/SCF_ventricles_masks','mascara.img'));
mask    = logical(spm_read_vols(header));


sessionCounter = 0;

if strcmp(component,'firstcomponent')
    fromImage   = 0;    %scans from - to
    toImage     = 8;
elseif strcmp(component,'secondcomponent')
    fromImage   = 9;
    toImage     = 20;
end

nSubjects       = 3;

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
        
        sessionCounter = sessionCounter + 1;
        
        directoryIn = fullfile(MAIN_DIRECTORY,'data/Analyze_data',['subject',num2str(iSub)],...
            ['SleepDataSubject',num2str(iSub),'Session',sprintf('%0.2i', iSess)],...
            ['swImagesSub',sprintf('%0.2i', iSub),'session',sprintf('%0.2i', iSess),'CovariatesOut']);
        
        cd(directoryIn)
        images  = dir('0*.nii');
        
        for iImage = 1:size(images,1)
            header                      = spm_vol(images(iImage).name);
            scan                        = spm_read_vols(header);
            matrix(:,:,:,iImage) = scan;
        end
        
        onsetsWakeUp = dataOnsets.sub(iSub).sess(iSess).wakingUpOnset;

        
        matrixSessionAllOnsets  = [];
        for iWakeUp = 1:length(onsetsWakeUp)
            
            from   = onsetsWakeUp(iWakeUp) + fromImage;
            to     = onsetsWakeUp(iWakeUp) + toImage;
            
            if from < 1, continue,end
            if to > size(matrix,4), continue,end
            
            matrixSessionAllOnsets = cat(5, matrixSessionAllOnsets, matrix(:,:,:,from:to));
        end
        
        matrixSessionAllOnsets              = reshape(matrixSessionAllOnsets,53*63*52,size(matrixSessionAllOnsets,4),size(matrixSessionAllOnsets,5));
        matrixSessionAllOnsets              = matrixSessionAllOnsets(mask,:,:);
        matrixSession(sessionCounter,:,:)   = squeeze(mean(matrixSessionAllOnsets,3));
    end
end

matrixSession = squeeze(mean(matrixSession));

folderOut = fullfile(MAIN_DIRECTORY,'results/lags/matrixSession_noresamp',component);
if(not(exist(folderOut)))
    mkdir(folderOut)
end
cd(folderOut)

save([component, '_data_matrix_noresamp'],'matrixSession','-ascii')


