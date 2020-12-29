function plot_hist()
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
close all

violet          = [117,107,177]/255;
green           = [49,163,84]/255;


addpath /home/pablo/disco/utiles/toolboxes/spm12/

MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';

addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/plot2svg/
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/exportfig/

header  = spm_vol(fullfile(MAIN_DIRECTORY,'scripts/preprocessing/SCF_ventricles_masks','mascara.img'));
mask    = logical(spm_read_vols(header));


cd(fullfile(MAIN_DIRECTORY,'results/lags/TD_noresamp/firstcomponent/'))
header  = spm_vol('firstcomponent_noresamp.nii');
m1 = spm_read_vols(header);
m1 = m1(mask);

cd(fullfile(MAIN_DIRECTORY,'results/lags/TD_noresamp/secondcomponent/'))
header  = spm_vol('secondcomponent_noresamp.nii');
m2 = spm_read_vols(header);
m2 = m2(mask);


figure
[h, x] = hist(m1,300);
han = area(x,smooth(h),'FaceColor',green,'lineStyle','none');
% alpha(han, 0.45 )
xlim([-7.5 4])
% hold on
% plot([0 0 ],[0 3200],'Color',[.3 .3 .3])
box off
set(gca,'Ytick',[]);
set(gca,'Xtick',[-6, -3, 0, 3]);
%
cd /home/pablo/Dropbox/trabajo/textos/011-Sleep-Kamitani/figures/from_matlab/lags/TDnoresamp/
opts.Format  = 'eps';
opts.Width   = 2;
opts.FontMode = 'fixed';
opts.Color = 'RGB';
opts.FontSize = 12;
exportfig(gcf,'hist1.eps',opts);

figure
[h, x] = hist(m2,500);
han = area(x,smooth(h),'FaceColor',violet,'lineStyle','none');
% alpha(han, 0.45 )
xlim([-7 7])

% hold on
% plot([0 0 ],[0 4700],'Color',[.3 .3 .3])

set(gca,'Ytick',[]);
set(gca,'Xtick',[-5 0 5]);

box off
exportfig(gcf,'hist2.eps',opts);
