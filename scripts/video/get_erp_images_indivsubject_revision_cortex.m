% function get_erp_images_indivsubject_revision_cortex()
clc
spm_path = '/home/pablo/disco/utiles/toolboxes/spm12';
addpath(spm_path)
MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';

addpath /home/pablo/disco/utiles/toolboxes/funciones_utiles/
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/exportfig/
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/plot2svg/
figure_defaults

figures_folder = '/home/pablo/Dropbox/trabajo/textos/011-Sleep-Kamitani/figures/from_matlab/figures_rev_cortex';
%%

load(fullfile(MAIN_DIRECTORY,'data/dataOnsets_video.mat'));

header  = spm_vol(fullfile(MAIN_DIRECTORY,'scripts','264Rois_all.nii'));
allRoi  = spm_read_vols(header);

header  = spm_vol(fullfile(MAIN_DIRECTORY,'scripts/preprocessing/SCF_ventricles_masks','mascara.img'));
mask    = logical(spm_read_vols(header));


timeSeriesAllSessions     = [];
usefulSessions            = [];
sessionCounter            = 0;
before_onset              = 15;
after_onset               = 34;
nSubjects                 = 3;
matrixSessionAllSessions  = zeros(53, 63, 52, before_onset + after_onset +1);


for iSub = 1
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
        
        directoryIn = fullfile(MAIN_DIRECTORY,'data/Analyze_data',['subject',num2str(iSub)],...
             ['SleepDataSubject',num2str(iSub),'Session',sprintf('%0.2i', iSess)],...
             ['swImagesSub',sprintf('%0.2i', iSub),'session',sprintf('%0.2i', iSess),'CovariatesOut']);
        
        cd(directoryIn)
        images  = dir('0*.nii');
        
        timeSeries      = nan(264,size(images,1));
        
        for iImage = 1:size(images,1)
            header                      = spm_vol(images(iImage).name);
            scan                        = spm_read_vols(header);
            for iRoi = 1:264                
                timeSeries(iRoi,iImage) = mean(scan(allRoi == iRoi ));
            end            
        end
        
        for iRoi = 1:264
            timeSeries(iRoi,:) = detrend(timeSeries(iRoi,:));
        end
        
        onsetsWakeUp = dataOnsets.sub(iSub).sess(iSess).wakingUpOnset;
        
        timeSeriesAllOnsets     = [];
        
        for iWakeUp = 1:length(onsetsWakeUp)
            from                    = onsetsWakeUp(iWakeUp) - before_onset;
            to                      = onsetsWakeUp(iWakeUp) + after_onset;
            
            if from < 1, continue,end
            if to > length(timeSeries), continue,end

            timeSeriesAllOnsets = cat(3,timeSeriesAllOnsets, timeSeries(:,from:to));
            CONTses = CONTses + 1;
        end
    
        timeSeriesAllSessions     = cat(3,timeSeriesAllSessions, mean(timeSeriesAllOnsets,3));
    end
end

%%

% networks = {'1 uncertain',...
% '2 sensory somatomotor hand',...
% '3 Sensory/somatomotor Mouth',...
% '4 Cingulo-opercular Task Control',...
% '5 Auditory',...
% '6 default',...
% '7 Memory retrieval',...
% '8 Ventral attention',...
% '9 Visual',...
% '10 Fronto-parietal Task Control',...
% '11 Salience',...
% '12 Subcortical',...
% '13 cerebellar',...
% '14 dorsal attention'};

identity = load(fullfile(MAIN_DIRECTORY,'scripts/264rois_identity.txt'));

nets = unique(identity);

[idsort xx ] =sort(identity);
netcount = [];
for i = 1:length(nets);
    netcount = [netcount length(find(idsort ==nets(i)))];
end
netcount = [cumsum(netcount)];    

a = mean(timeSeriesAllSessions,3);
sortedmatrix = a(xx,:);

orange          = [249, 145, 88]/255;
blue            = [105, 173, 222]/255;
green           = [49,163,84]/255;
violet          = [117,107,177]/255;


%% imagesc
cd(fullfile(figures_folder,'video',['subject' num2str(iSub)]))


figure, hold on
imagesc(-before_onset:after_onset,1:264,sortedmatrix)

for i = 1:length(netcount)
    line([-.5-before_onset,after_onset + .5],[netcount(i) netcount(i)],'Color','w','linewidth',.5)
%     disp(['red' num2str(i),' ' num2str(sum(identity==i))])
     
end
line([0 0],[1 264],'Color','k','linewidth',.8)
axis tight
set(gca,'yTickLabels',[])
set(gca,'xTick',-10:10:40)
caxis([-6 6]);
set(gcf,'Position',[    678   578   686   400]);
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/
opts.Format  = 'eps';
opts.Width   = 3;
opts.FontMode = 'fixed';
opts.Color = 'RGB';
opts.FontSize = 8;
exportfig(gcf,['ROIvsTime_',['subject' num2str(iSub)],'.eps'],opts);


%% zoom

figure, hold on
imagesc(-before_onset:after_onset,1:264,sortedmatrix)
for i = 1:length(netcount)
    line([-.5-before_onset,after_onset + .5],[netcount(i) netcount(i)],'Color','w','linewidth',.5)
end
line([0 0],[1 264],'Color','k','linewidth',.8)
axis tight
set(gca,'xTickLabels',[])
set(gca,'yTickLabels',[])
caxis([-5 5]);
xlim([-1 25])
ylim([230 250])
set(gcf,'Position',[716   500   683   173]);
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/
opts.Format  = 'eps';
opts.Width   = 3;
opts.FontMode = 'fixed';
opts.Color = 'RGB';
opts.FontSize = 8;
exportfig(gcf,['ROIvsTimeZOOM_',['subject' num2str(iSub)],'.eps'],opts);





%% average
time_before = -before_onset:0;
time_after  = 0:after_onset;
clear N
for iNet = 1:size(nets,1)
    inds = find(identity == iNet);
    N(iNet,:,:) = mean(timeSeriesAllSessions(inds,:,:));    
end
av = detrend(squeeze(mean(N,1)));

Naverage = mean(av,2)';
Naverage = Naverage - mean(Naverage(1:length(time_before))); % baseline correction

Eaverage = std(av ,0,2) / sqrt(size(av,2))';

figure, hold all
niceBars(time_before,Naverage(1:length(time_before)),Eaverage(1:length(time_before))',blue,.6)
niceBars(time_after, Naverage(end-after_onset:end),Eaverage(end-after_onset:end)',orange,.6)
line([-15 35],[0 0],'Color','k','linewidth',.8)
axis tight
set(gcf,'Position',[    678   578   686   400]);

exportfig(gcf,['timecourse_',['subject' num2str(iSub)],'.eps'],opts);


%% thalamic rois
time_before = -before_onset:0;
time_after  = 0:after_onset;

inds_sorted = [238, 239];
inds        = xx(inds_sorted);

N    = mean(timeSeriesAllSessions(inds,:,:));    

av = detrend(squeeze(mean(N,1)));

Naverage = mean(av,2)';
Naverage = Naverage - mean(Naverage(1:length(time_before))); % baseline correction

Eaverage = std(av ,0,2) / sqrt(size(av,2))';

figure, hold all
niceBars(time_before,Naverage(1:length(time_before)),Eaverage(1:length(time_before))',blue,.6)
niceBars(time_after, Naverage(end-after_onset:end),Eaverage(end-after_onset:end)',orange,.6)
line([-15 35],[0 0],'Color','k','linewidth',.8)
axis tight
set(gcf,'Position',[    678   578   686   400]);
set(gca,'xTickLabels',[])
set(gca,'yTickLabels',[])
axis off

exportfig(gcf,['timecourseTHAL_',['subject' num2str(iSub)],'.eps'],opts);


%% individual nets


for iNet = 1:size(N,1)
    
    M = detrend(mean(N(iNet,:,:),3));    
    M = M - mean(M(1:length(time_before))); % baseline correction

    E = std(N(iNet,:,:),0,3) / sqrt(size(N,3));

    figure, hold all
    niceBars(time_before,M(1:length(time_before)),E(1:length(time_before)),blue,.6)
    niceBars(time_after, M(end-after_onset:end),E(end-after_onset:end),orange,.6)
    axis tight
    line([-15 35],[0 0],'Color','k','linewidth',.8)
    set(gcf,'Position',[    678   578   686   400]);
    axis off
    exportfig(gcf,['net' num2str(iNet),['_subject' num2str(iSub)],'.eps'],opts);
end
