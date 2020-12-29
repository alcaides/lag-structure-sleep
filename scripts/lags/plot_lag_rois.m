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


MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/exportfig/

cd(fullfile(MAIN_DIRECTORY,'results/lags/TD'))

include_auditory_rois = 1;

if include_auditory_rois
    firstc = load('meanLags_auditoryrois_firstcomponent');
    secondc = load('meanLags_auditoryrois_secondcomponent');
else
    firstc = load('meanLags_firstcomponent');
    secondc = load('meanLags_secondcomponent');
end

figure, hold on
plot(firstc.meanLagsBack,secondc.meanLagsBack,'o','markersize',2,'MarkerFaceColor','black','MarkerEdgeColor','none')
h = lsline;
set(h(1),'color','k')
box off
set(gca,'Xtick',-2:.5:.8)
set(gca,'Ytick',-.6:.4:.6)
xlim([-1.8 .9])


cd /home/pablo/Dropbox/trabajo/textos/011-Sleep-Kamitani/figures/from_matlab/lags
opts.Format  = 'eps';
opts.Width   = 1.5;
opts.FontMode = 'fixed';
opts.Color = 'RGB';
opts.FontSize = 7;
axis tight
if include_auditory_rois
    exportfig(gcf,'lagvslag_auditory.eps',opts);
else
    exportfig(gcf,'lagvslag.eps',opts);
end
        

[c r ] = corrcoef(firstc.meanLagsBack,secondc.meanLagsBack)
