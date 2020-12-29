function lag_rois_per_subject_revision_cortex()
clc
close all
spm_path            = '/home/pablo/disco/utiles/toolboxes/spm12';
addpath(spm_path)
MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';



header  = spm_vol(fullfile(MAIN_DIRECTORY,'scripts','264_small.nii'));
allRoi  = spm_read_vols(header);

header  = spm_vol(fullfile(MAIN_DIRECTORY,'scripts/preprocessing/SCF_ventricles_masks','mascara.img'));
mask    = logical(spm_read_vols(header));


iSub = 1



fprintf('Read data for Subject %d\n',iSub);

switch iSub
    case 1
        nSleepDataSessions = 1:26;
    case 2
        nSleepDataSessions = 27:40;
    case 3
        nSleepDataSessions = 41:55;
end

sessionCounter = 0;

for iSess = nSleepDataSessions
    
    sessionCounter = sessionCounter + 1;
    disp(sessionCounter)
    

    cd(fullfile(MAIN_DIRECTORY,'results/lags/TD','firstcomponent','volumes'))
    header = spm_vol(['firstcomponent_', sprintf('%0.2i', iSess), '.nii']);
    scan1   = spm_read_vols(header);
    
    cd(fullfile(MAIN_DIRECTORY,'results/lags/TD','secondcomponent','volumes'))
    header = spm_vol(['secondcomponent_', sprintf('%0.2i', iSess), '.nii']);
    scan2   = spm_read_vols(header);

    for iRoi = 1:264
        roilags_1(iRoi,sessionCounter) = mean(scan1(allRoi == iRoi ));
        roilags_2(iRoi,sessionCounter) = mean(scan2(allRoi == iRoi ));
    end
end


identity = load(fullfile(MAIN_DIRECTORY,'scripts/264rois_identity.txt'));

nets = unique(identity);

[idsort xx ] =sort(identity);

orange          = [249, 145, 88]/255;
blue            = [105, 173, 222]/255;
green           = [49,163,84]/255;
violet          = [117,107,177]/255;

%% average
cd(fullfile('/home/pablo/Dropbox/trabajo/textos/011-Sleep-Kamitani/figures/from_matlab/figures_rev_cortex/lags',['subject',num2str(iSub)]))

for iNet = 2:size(nets,1)
    inds = find(identity == iNet);
    N_1(iNet-1,:) = mean(roilags_1(inds,:));    
    N_2(iNet-1,:) = mean(roilags_2(inds,:));    
end


meanLags1 = mean(N_1,2);
errLags1 = std(N_1 ,0,2) / sqrt(size(N_1,2));

meanLags2 = mean(N_2,2);
errLags2 = std(N_2 ,0,2) / sqrt(size(N_2,2));


[~,order1] = sort(meanLags1);
[~,order2] = sort(meanLags2);

meanLags1_sort = meanLags1(order1);
errLags1_sort  = errLags1(order1);

meanLags2_sort = meanLags2(order2);
errLags2_sort  = errLags2(order2);

           % rojo      % azul      % verde     amarillo       rosa             marron     
colors = [[255, 0, 0]; [0, 0, 153];[0, 102, 0]; [255, 204, 0]; [255, 51, 153]; [153, 102, 51 ];...
    ...  celeste       verdeazul      naranja          fucsia          gris            negro   bordo
        [51, 204, 255]; [0, 102, 102]; [255, 153, 0]; [204, 51, 255]; [102, 102, 102];[0 0 0];[128, 0, 0]];    

colors = colors / 255;

colors1 = colors(order1,:);
colors2 = colors(order2,:);

addpath /home/pablo/disco/utiles/toolboxes/funciones_utiles/
figure_defaults

figure
hold on
for i = 1:length(meanLags1_sort)
    plot([meanLags1_sort(i) - errLags1_sort(i), meanLags1_sort(i) + errLags1_sort(i)],[i i],'color',colors1(i,:),'LineWidth',3);
end
set(gca,'YTick',[])
set(gca,'Xtick',-3:1:1)

xlim([-3 1])
set_figure_size(8)
print(['lags_component1' ['subject',num2str(iSub)],'.eps'],'-depsc')
%


figure
hold on
for i = 1:length(meanLags2_sort)
    plot([meanLags2_sort(i) - errLags2_sort(i), meanLags2_sort(i) + errLags2_sort(i)],[i i],'color',colors2(i,:),'LineWidth',3);
end
xlim([-2.2 1.5])
set(gca,'YTick',[])
set(gca,'Xtick',-2:1:1)

set_figure_size(8)
print(['lags_component2' ['subject',num2str(iSub)],'.eps'],'-depsc')

%

figure
hold on
plot(meanLags1, meanLags2,'k.','markersize',10)
h = lsline;
set(h(1),'color','k')
box off
set(gca,'Xtick',-3:1:1)
set(gca,'Ytick',-1:.5:2)
axis tight

set_figure_size(8)
print(['lagvslag_',['subject',num2str(iSub),'.eps']],'-depsc')
