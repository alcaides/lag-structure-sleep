 function make_movie_revision_cortex()
% =========================================================================
% reads fusioned images and makes a video
%
% Syntax: make_movie
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
green           = [76, 184, 72]/255;
before_onset    = 15;
after_onset     = 34;

MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';
FIGURES_PATH = '/home/pablo/Dropbox/trabajo/textos/011-Sleep-Kamitani/figures/from_matlab';

addpath /home/pablo/disco/utiles/toolboxes/funciones_utiles/
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/exportfig/
addpath /home/pablo/disco/utiles/toolboxes/plot_matlab/plot2svg/
figure_defaults


directoryIn     = fullfile(MAIN_DIRECTORY,'results/video/images_movie');

vidObj              = VideoWriter(fullfile(FIGURES_PATH,'figures_rev_cortex/video/movie.avi'));
vidObj.FrameRate    = 4;
vidObj.Quality      = 100;

open(vidObj);

load(fullfile(MAIN_DIRECTORY,'results/video/timeSeries.mat'))
timeSeries = Naverage;
errortimeSeries = Eaverage;

figure
set(gcf,'Position',[401   126   655   540])
   
time_before = -before_onset:0;
time_after  = 0:after_onset;

for iImage = 1:length(timeSeries)
    clf
    
    image1 = imread(fullfile(directoryIn, '/sagital/', [sprintf('%03d',iImage),'.png']));
    image2 = imread(fullfile(directoryIn, 'axial/', [sprintf('%03d',iImage),'.png']));

    subplot(2,2,1)
    image(image1)
    daspect([1 1 1])
    axis off
    
    subplot(2,2,2)
    image(image2)
    daspect([1 1 1])
    axis off
    
    subplot(2,2,[3 4])
    plot(-before_onset:after_onset,timeSeries,'Color',blue,'linewidth',2);
    axis tight
    box off
    hold on
    plot(0:after_onset,timeSeries(end-after_onset:end),'Color',orange,'linewidth',2);
    legend({'Asleep','Awake'})
    
    image1 = imread(fullfile(directoryIn, '/sagital/', [sprintf('%03d',iImage),'.png']));
    image2 = imread(fullfile(directoryIn, 'axial/', [sprintf('%03d',iImage),'.png']));

    subplot(2,2,1)
    image(image1)
    daspect([1 1 1])
    axis off
    
    subplot(2,2,2)
    image(image2)
    daspect([1 1 1])
    axis off

    subplot(2,2,[3 4])
    niceBars(time_before,timeSeries(1:length(time_before)),errortimeSeries(1:length(time_before))',blue,.6)
    niceBars(time_after, timeSeries(end-after_onset:end),errortimeSeries(end-after_onset:end)',orange,.6)
    hold on
    plot(iImage-before_onset-1,timeSeries(iImage),'o','MarkerFaceColor',green,'MarkerEdgeColor',green,'Markersize',6);
    axis tight
    xlabel('Time (scans)')
    ylabel('BOLD signal (a.u.)')
%     legend({'Asleep','Awake'})
    

%     axes('Position',[0.15 0.3 0.1 0.1])    
%     imagesc(roi)
%     daspect([1 1 1])
%     axis off

    pause(1)
    currFrame = getframe(gcf);
    
    
    
    writeVideo(vidObj,currFrame);
end
close(vidObj);
