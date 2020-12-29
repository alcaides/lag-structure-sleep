function plot_waking_up()
% =========================================================================
% reads fusioned images and plots a figure version of the video.
%
% Syntax: plot_waking_up
%
% Other m-files required: spm12
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

close all

orange          = [249, 145, 88]/255;
blue            = [105, 173, 222]/255;
green           = [49,163,84]/255;
violet          = [117,107,177]/255;
before_onset    = 15;
after_onset     = 34;

overwrite = input('overwrite images? Y/N [Y]:','s');
if strcmpi(lower(overwrite),'n'), return
elseif not(strcmpi(lower(overwrite),'y'))
    warning('options are Y or N');return
end


MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';
FIGURES_PATH = '/home/pablo/Dropbox/trabajo/textos/011-Sleep-Kamitani/figures/from_matlab';

directoryIn     = fullfile(MAIN_DIRECTORY,'results/video/images_movie');

addpath /home/pablo/disco/utiles/toolboxes/funciones_utiles/
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/exportfig/
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/plot2svg/
figure_defaults

load(fullfile(MAIN_DIRECTORY,'results/video/timeSeries.mat'))
timeSeries = mean(timeSeriesAllSessions);
errortimeSeries = std(timeSeriesAllSessions) / sqrt(size(timeSeriesAllSessions,1));

% figure, hold on;
% plot(-before_onset:after_onset,timeSeries,'Color',blue,'linewidth',1.5);axis tight
% box off
% hold on
% plot(0:after_onset,timeSeries(end-after_onset:end),'Color',orange,'linewidth',1.5);

time_before = -before_onset:0;
time_after  = 0:after_onset;

figure, hold on;
niceBars(time_before,timeSeries(1:length(time_before)),errortimeSeries(1:length(time_before)),blue,.6)
niceBars(time_after, timeSeries(end-after_onset:end),errortimeSeries(end-after_onset:end),orange,.6)

set(gcf,'Position',[ 401   428   672   238]);
set(gca,'Ytick',0:2:12)
set(gca,'Yticklabel',0:2:12)
axis tight 

cd(fullfile(FIGURES_PATH,'video'))
opts.Format  = 'eps';
opts.Width   = 3;
opts.FontMode = 'fixed';
opts.Color = 'RGB';
opts.FontSize = 8;
exportfig(gcf,'timecourse.eps',opts);


%

figure, 
clf
hold on;
plot(-before_onset:after_onset,timeSeries,'Color',[.65 .65 .65],'linewidth',1.5);
axis tight
box off
set(gcf,'Position',[ 401   428   672   238]);
set(gca,'Ytick',0:2:12)

from= 0;
to = 8.5;
han = fill([to  from from  to],[4.7 4.7 -.5  -.5 ],green,'LineWidth',.1,'FaceColor',green,'EdgeColor',green,'LineStyle','none');
alpha(han, 0.45 )

from= 8.5;
to = 20;
han = fill([to  from from  to],[4.7 4.7 -.5  -.5 ],violet,'LineWidth',.1,'FaceColor',violet,'EdgeColor',violet,'LineStyle','none');
alpha(han, 0.45 )
set(gca,'Xtick',[]);
set(gca,'Ytick',[]);
%
opts.Format  = 'eps';
opts.FontMode = 'fixed';
opts.Color = 'RGB';
opts.FontSize = 8;
plot2svg('tc.svg',gcf,'png')


images = [5 19 20 24 30];

cd(fullfile(FIGURES_PATH,'video'))
for iImage = images;
    image1 = imread(fullfile(directoryIn, '/sagital/', [sprintf('%03d',iImage),'.png']));
    image2 = imread(fullfile(directoryIn, 'axial/', [sprintf('%03d',iImage),'.png']));
    
    figure, image(image2)
    opts.Width   = 1.2;
    daspect([1 1 1]), axis off
    exportfig(gcf,[sprintf('axial_%02d',iImage),'.eps'],opts);
    
    figure, image(image1)
    opts.Width   = 1;
    daspect([1 1 1]), axis off
    exportfig(gcf,[sprintf('sagittal_%02d',iImage),'.eps'],opts);
end  


% figure
% colormap('jet')
% colorbar('TickLabels',{''})
% axis off
% exportfig(gcf,'colorbar.eps',opts);

