function get_erp_images_supplementary()
% =========================================================================
% reads raw images and gets a erp image for supporting figs
%
% Syntax: get_erp_images_supplementary
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

load(fullfile(MAIN_DIRECTORY,'data/dataOnsets_video.mat'));

header          = spm_vol(fullfile(MAIN_DIRECTORY,'scripts/preprocessing/SCF_ventricles_masks','mascara.img'));
mask            = logical(spm_read_vols(header));

cd(fullfile(MAIN_DIRECTORY,'/results/GLM/rois/rois_glm'))
rois= dir('*.img');

ROIS = {};
cont = 0;
for i = 1:length(rois)
    name = rois(i).name;
    if strcmp(name(1),'r'),continue,end
    cont = cont + 1;
    header = spm_vol(name);
    ROIS{cont} = logical(spm_read_vols(header));
end
timeSeriesAllSessions     = [];
usefulSessions            = [];
sessionCounter            = 0;
before_onset              = 15;
after_onset               = 34;
nSubjects                 = 3;

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
        sessionCounter = sessionCounter + 1;
        fprintf('Sleep data loading(%d/%d)\n',iSess,nSleepDataSession)
        
        directoryIn     = fullfile(MAIN_DIRECTORY,'data/Analyze_data',...
            ['subject',num2str(iSub)],['SleepDataSubject',num2str(iSub),'Session',sprintf('%02d',iSess)],...
            ['swImagesSub',sprintf('%02d',iSub),'session',sprintf('%02d',iSess),'Movements']);

        cd(directoryIn)        
        images  = dir('0*.nii');
        
        brain = zeros(length(mask(:)),length(images));
        for iImage = 1:size(images,1)
            header                      = spm_vol(images(iImage).name);
            scan                        = spm_read_vols(header);
            brain(:,iImage)             = scan(:);
        end
        
        
        for r = 1:size(ROIS,2)
            timeSeriesAllOnsets = [];
            timeSeries  = mean(brain(ROIS{r},:));
            timeSeries = detrend(timeSeries);


            onsetsWakeUp = dataOnsets.sub(iSub).sess(iSess).wakingUpOnset;
            
            timeDifference          = diff(onsetsWakeUp);
            timeSeriesAllOnsets     = [];
            for iWakeUp = 1:length(onsetsWakeUp)
                from                    = onsetsWakeUp(iWakeUp) - before_onset;
                to                      = onsetsWakeUp(iWakeUp) + after_onset;
                
                if from < 1, continue,end
                if to > length(timeSeries), continue,end
                
                if iWakeUp ~= length(onsetsWakeUp) 
                    if timeDifference(iWakeUp) < after_onset
                        continue
                    end
                end
                
                timeSeriesAllOnsets    = [timeSeriesAllOnsets; timeSeries(from:to)]; 
            end
            timeSeriesAllSessions(sessionCounter,r,:) = mean(timeSeriesAllOnsets);            
        end
    end
end


%%
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/exportfig/
ts = squeeze(mean(timeSeriesAllSessions));
before_onset    = 15;
after_onset     = 34;


figure, hold all
plot(-before_onset:after_onset,ts','linewidth',1.5);
box off
axis tight
set(gca,'xtick',-10:10:50)


cd(fullfile(FIGURES_PATH,'video'))
opts.Format  = 'eps';
opts.Width   = 2.5;
opts.FontMode = 'fixed';
opts.Color = 'RGB';
opts.FontSize = 8;
exportfig(gcf,'figureS1.eps',opts);

figure
plot(-before_onset:after_onset,mean(ts),'linewidth',1.5);
box off
axis tight
set(gca,'xtick',-10:10:50)
set(gca,'ytick',-2:2:4)
exportfig(gcf,'figureS2.eps',opts);


        