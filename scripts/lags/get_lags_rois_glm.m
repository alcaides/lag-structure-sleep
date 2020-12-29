% function get_lags_rois_glm()
% =========================================================================
% - calculates cross correlation between each voxel signal
% Syntax: calculate_lag_matrices

% Other m-files required: corr_matricial, mex function
% Subfunctions: none
% MAT-files required: none
%
% Authors: Alvaro Romano and Santiago Alcaide
% Laboratorio de Ciencias Cognitivas, Cordoba Argentina
% email: alvaroromano13@gmail.com; santiago_asa@gmail.com
% Website: cognitivas.github.io
% Oct 2018; Last revision: 30-Oct-2018
% =========================================================================
clear
clc
close all

component = 'firstcomponent'; % first/secondcomponent;
% component = 'secondcomponent'; % first/secondcomponent;

include_auditory_rois = 0;

maxSession = 55;

MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/exportfig/


dir_rois =  fullfile(MAIN_DIRECTORY,'results','GLM/rois/rois_glm/');


cd(dir_rois)
rois = dir('r*.img'); 

if include_auditory_rois

    rois_spheres = dir('*.nii');
    for iRoi = 1:numel(rois_spheres)
        rois(end+1) = rois_spheres(iRoi);
    end
end

directoryIn = fullfile(MAIN_DIRECTORY,'data/Analyze_data',['subject',num2str(1)],...
    ['SleepDataSubject',num2str(1),'Session',sprintf('%0.2i', 1)],...
    ['swImagesSub',sprintf('%0.2i', 1),'session',sprintf('%0.2i', 1),'CovariatesOut']);

cd(directoryIn)

images  = dir('0*.nii');

header2 = spm_vol(images(1).name);
image   = spm_read_vols(header2);

header  = spm_vol(fullfile(MAIN_DIRECTORY,'scripts/lags','rmascara.img'));
mask    = logical(spm_read_vols(header));

for iRoi = 1:length(rois)
    
    header  = spm_vol(fullfile(dir_rois, rois(iRoi).name));
    roi     = spm_read_vols(header);
    roi(isnan(roi)) = 0;
    allRoi{iRoi}     = logical(roi);
end


for iSub =  1:maxSession     
    cd (fullfile(MAIN_DIRECTORY,'results/lags/TD',component,'volumes'));
    
    fprintf('working on matrix %d out of %d\n', iSub,maxSession)
    
    header = spm_vol(sprintf([component,'_%02d.nii'],iSub));
    volume = spm_read_vols(header);

    for iRoi = 1:length(rois)
        lags(iSub,iRoi) = nanmean(volume(allRoi{iRoi}));
    end
end

%%

meanLags   = nanmean(lags);
errLags    = nanstd(lags) / sqrt(55);

[bla,order] = sort(meanLags);

meanLagsBack = meanLags;
errLagsBack = errLags;


cd(fullfile(MAIN_DIRECTORY,'results/lags/TD'))
if include_auditory_rois
    save(['meanLags_auditoryrois_' component],'meanLagsBack');
else
    save(['meanLags_' component],'meanLagsBack');
end
meanLags = meanLags(order);
errLags  = errLags(order);

%%
cmap = colormap(jet(ceil(max(abs(meanLags))*100 *2)));
meanColor = round(meanLags * 100);
meanColor = round(meanColor + size(cmap,1)/2);            
if meanColor <= 0
    meanColor = 1;
end

hold on
for i = 1:length(meanLags)
    plot([meanLags(i) - errLags(i), meanLags(i) + errLags(i)],[i i],'color',cmap(meanColor(i),:),'LineWidth',1.2);
end
set(gca,'YTick',[])
%%

if not(include_auditory_rois)
    if strcmp(component,'firstcomponent')
        xlim([-1.2 1.4])
    end
    if strcmp(component,'secondcomponent')
        set(gca,'Xtick',[-.8:.4:1])
    end
end
cd /home/pablo/Dropbox/trabajo/textos/011-Sleep-Kamitani/figures/from_matlab/lags
opts.Format  = 'eps';
opts.Width   = 1.5;
opts.FontMode = 'fixed';
opts.Color = 'RGB';
opts.FontSize = 7;
if include_auditory_rois
    exportfig(gcf,['rois_' component,'_auditoryrois.eps'],opts);
else
    exportfig(gcf,['rois_' component,'.eps'],opts);
end


%%
clc
rois(order).name
 