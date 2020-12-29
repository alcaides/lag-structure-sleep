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


component = 'firstcomponent';
% component = 'secondcomponent';

cd(fullfile(MAIN_DIRECTORY,'results/lags/TD',component,'volumes'))

iSub = 2.;

switch iSub
    case 1
        nSleepDataSessions = 1:26;
    case 2
        nSleepDataSessions = 27:40;
    case 3
        nSleepDataSessions = 41:55;
end

Av = 0;
sessionCounter = 0;
for iSess = nSleepDataSessions
    sessionCounter = sessionCounter + 1

    header = spm_vol([component,'_', sprintf('%0.2i', iSess), '.nii']);
    scan   = spm_read_vols(header);
    
    Av = Av + scan;
end

Av = Av / sessionCounter;

cd ..

header.fname = ['Average_',component,'_subject', num2str(iSub),'.nii' ];
spm_write_vol(header,Av);
    
