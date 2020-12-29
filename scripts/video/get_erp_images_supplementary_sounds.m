% function get_erp_images_supplementary_sounds()
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
FIGURES_PATH = '/home/pablo/Dropbox/trabajo/textos/011-Sleep-Kamitani/figures/from_matlab';

load(fullfile(MAIN_DIRECTORY,'data/dataOnsetsGLM.mat'));

header          = spm_vol(fullfile(MAIN_DIRECTORY,'scripts','video','thalamusFWE00005.img'));

thalamusMask    = spm_read_vols(header);
thalamusMask    = logical(thalamusMask);

header          = spm_vol(fullfile(MAIN_DIRECTORY,'scripts/preprocessing/SCF_ventricles_masks','mascara.img'));
mask            = logical(spm_read_vols(header));


timeSeriesAllSessions1    = []; 
timeSeriesAllSessions2    = []; 
timeSeriesAllSessions3    = []; 
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
        end
        timeSeries = detrend(timeSeries);

        
        onsetsWakeUp1 = dataOnsets.sub(iSub).sess(iSess).SoundTimes;
        onsetsWakeUp2 = dataOnsets.sub(iSub).sess(iSess).SoundTimes_Response;
        onsetsWakeUp3 = dataOnsets.sub(iSub).sess(iSess).SoundTimes_NoResponse;
        
        % SoundTimes    
        timeDifference          = diff(onsetsWakeUp1);
        timeSeriesAllOnsets     = [];
        for iWakeUp = 1:length(onsetsWakeUp1)
            from                    = onsetsWakeUp1(iWakeUp) - before_onset;
            to                      = onsetsWakeUp1(iWakeUp) + after_onset;
        
            from = round(from);
            to   = round(to);
            if from < 1, continue,end
            if to > length(timeSeries), continue,end 
            
            timeSeriesAllOnsets    = [timeSeriesAllOnsets; timeSeries(from:to)];
            CONTses = CONTses + 1;
        end
        try
            timeSeriesAllSessions1     = [timeSeriesAllSessions1; mean(timeSeriesAllOnsets)];
        end
        % SoundTimes Responses   
        timeDifference          = diff(onsetsWakeUp2);
        timeSeriesAllOnsets     = [];
        for iWakeUp = 1:length(onsetsWakeUp2)
            from                    = onsetsWakeUp2(iWakeUp) - before_onset;
            to                      = onsetsWakeUp2(iWakeUp) + after_onset;
        
            from = round(from);
            to   = round(to);
            if from < 1, continue,end
            if to > length(timeSeries), continue,end 
            
            timeSeriesAllOnsets    = [timeSeriesAllOnsets; timeSeries(from:to)];
            CONTses = CONTses + 1;
        end
        try
            timeSeriesAllSessions2     = [timeSeriesAllSessions2; mean(timeSeriesAllOnsets)];
        end
        % SoundTimes No Responses   
        timeDifference          = diff(onsetsWakeUp3);
        timeSeriesAllOnsets     = [];
        for iWakeUp = 1:length(onsetsWakeUp3)
            from                    = onsetsWakeUp3(iWakeUp) - before_onset;
            to                      = onsetsWakeUp3(iWakeUp) + after_onset;
        
            from = round(from);
            to   = round(to);
            if from < 1, continue,end
            if to > length(timeSeries), continue,end 
            
            timeSeriesAllOnsets    = [timeSeriesAllOnsets; timeSeries(from:to)];
            CONTses = CONTses + 1;
        end
        try
            timeSeriesAllSessions3     = [timeSeriesAllSessions3; mean(timeSeriesAllOnsets)];
        end
        
        
        
    end
end
%%

addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/exportfig/
before_onset    = 15;
after_onset     = 34;

figure, hold all
ts = detrend(mean(timeSeriesAllSessions1,1));
plot(-before_onset:after_onset,ts','linewidth',1.5);

ts = detrend(mean(timeSeriesAllSessions2,1));
plot(-before_onset:after_onset,ts','linewidth',1.5);

ts = detrend(mean(timeSeriesAllSessions3,1));
plot(-before_onset:after_onset,ts','linewidth',1.5);

box off
axis tight
set(gca,'xtick',-10:10:50)
ylim([-1.7 1.2])



cd(fullfile(FIGURES_PATH,'video'))
opts.Format  = 'eps';
opts.Width   = 2.5;
opts.FontMode = 'fixed';
opts.Color = 'RGB';
opts.FontSize = 8;
exportfig(gcf,'figureSsounds.eps',opts);


