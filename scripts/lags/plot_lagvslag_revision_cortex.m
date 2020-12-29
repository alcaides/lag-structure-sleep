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

MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/exportfig/

cd(fullfile(MAIN_DIRECTORY,'results','GLM'))
header  = spm_vol('overlap.nii');
mask    = spm_read_vols(header);

cd(fullfile(MAIN_DIRECTORY,'results/lags/TD_noresamp/firstcomponent'));
header  = spm_vol('firstcomponent_noresamp.nii');
first   = spm_read_vols(header);

cd(fullfile(MAIN_DIRECTORY,'results/lags/TD_noresamp/secondcomponent'));
header  = spm_vol('secondcomponent_noresamp.nii');
second  = spm_read_vols(header);


F = first(mask==3);
S = second(mask==3);



figure
plot(F,S,'k.','markersize',3.5)
h = lsline;
set(h(1),'color','k')
box off
set(gca,'Xtick',-6:2:4)
% set(gca,'Ytick',-6:4:10)
axis tight

cd /home/pablo/Dropbox/trabajo/textos/011-Sleep-Kamitani/figures/from_matlab/figures_rev_cortex/lags
opts.Format  = 'eps';
opts.Width   = 1.5;
opts.FontMode = 'fixed';
opts.Color = 'RGB';
opts.FontSize = 7;
exportfig(gcf,'lagvslag_voxelwise.eps',opts);

[c r ] = corrcoef(F,S)
    