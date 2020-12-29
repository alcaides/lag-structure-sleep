function get_erp_images()
% =========================================================================
% reads raw images and gets a sequence of images to make a video
%
% Syntax: get_erp_images
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
spm_path            = '/home/pablo/disco/utiles/toolboxes/spm12';
addpath(spm_path)
MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';

load(fullfile(MAIN_DIRECTORY,'data/dataOnsets_video.mat'));

header          = spm_vol(fullfile(MAIN_DIRECTORY,'scripts','video','thalamusFWE00005.img'));

thalamusMask    = spm_read_vols(header);
thalamusMask    = logical(thalamusMask);

header          = spm_vol(fullfile(MAIN_DIRECTORY,'scripts/preprocessing/SCF_ventricles_masks','mascara.img'));
mask            = logical(spm_read_vols(header));


timeSeriesAllSessions     = [];
usefulSessions            = [];
sessionCounter            = 0;
before_onset              = 15;
after_onset               = 34;
nSubjects                 = 3;
matrixSessionAllSessions  = zeros(53, 63, 52, before_onset + after_onset +1);

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
        
        CONTses = 0;
        sessionCounter = sessionCounter + 1;
        fprintf('Sleep data loading(%d/%d)\n',iSess,nSleepDataSession)
        
        directoryIn     = fullfile(MAIN_DIRECTORY,'data/Analyze_data',...
            ['subject',num2str(iSub)],['SleepDataSubject',num2str(iSub),'Session',sprintf('%02d',iSess)],...
            ['swImagesSub',sprintf('%02d',iSub),'session',sprintf('%02d',iSess),'Movements']);
        
        cd(directoryIn)
        images  = dir('0*.nii');
        
        timeSeries      = nan(1,size(images,1));
        matrixSession   = nan(size(thalamusMask,1),size(thalamusMask,2),size(thalamusMask,3),size(images,1));
        
        for iImage = 1:size(images,1)
            header                      = spm_vol(images(iImage).name);
            scan                        = spm_read_vols(header);
            timeSeries(iImage)          = mean(scan(thalamusMask));
            matrixSession(:,:,:,iImage) = scan;
        end
        timeSeries = detrend(timeSeries);
        
        onsetsWakeUp = dataOnsets.sub(iSub).sess(iSess).wakingUpOnset;
        
        timeSeriesAllOnsets     = [];
        matrixSessionAllOnsets  = [];
        
        for iWakeUp = 1:length(onsetsWakeUp)
            from                    = onsetsWakeUp(iWakeUp) - before_onset;
            to                      = onsetsWakeUp(iWakeUp) + after_onset;
            
            if from < 1, continue,end
            if to > length(timeSeries), continue,end

            timeSeriesAllOnsets    = [timeSeriesAllOnsets; timeSeries(from:to)];
            matrixSessionAllOnsets = cat(5, matrixSessionAllOnsets, matrixSession(:,:,:,from:to));
            CONTses = CONTses + 1;
        end
    
        timeSeriesAllSessions     = [timeSeriesAllSessions; mean(timeSeriesAllOnsets)];
        matrixSessionAllSessions  = matrixSessionAllSessions + zscore(mean(matrixSessionAllOnsets,5),0,4);
        usefulSessions            = [usefulSessions; CONTses, length(onsetsWakeUp)];
    end
end
%%
matrixSessionAllSessions = matrixSessionAllSessions  ./ sessionCounter;

cd(fullfile(MAIN_DIRECTORY,'results/video/images'))

for iImage = 1:size(matrixSessionAllSessions,4)
    header.fname = ['im_' sprintf('%03d',iImage) '.nii'];
    image = matrixSessionAllSessions(:,:,:,iImage);
    spm_write_vol(header,image);
end
cd ..
save('timeSeries','timeSeriesAllSessions','usefulSessions')

figure
plot(mean(timeSeriesAllSessions,1))

