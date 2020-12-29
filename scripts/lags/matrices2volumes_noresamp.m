% function matrices2volumes()
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

directoryIn = fullfile(MAIN_DIRECTORY,'data/Analyze_data',['subject',num2str(1)],...
    ['SleepDataSubject',num2str(1),'Session',sprintf('%0.2i', 1)],...
    ['swImagesSub',sprintf('%0.2i', 1),'session',sprintf('%0.2i', 1),'CovariatesOut']);

cd(directoryIn)
images  = dir('0*.nii');

header2 = spm_vol(images(1).name);

header  = spm_vol(fullfile(MAIN_DIRECTORY,...
            'scripts/preprocessing/SCF_ventricles_masks','mascara.img'));
        
mask    = logical(spm_read_vols(header));



cd (fullfile(MAIN_DIRECTORY,'results/lags/TD_noresamp/firstcomponent'));

load('firstc');
volume = zeros(size(mask));
volume(mask) = firstc;
   
header2.fname = 'firstcomponent_noresamp.nii';
spm_write_vol(header2,volume);

cd (fullfile(MAIN_DIRECTORY,'results/lags/TD_noresamp/secondcomponent'));

load('secondc');
volume = zeros(size(mask));
volume(mask) = secondc;
   
header2.fname = 'secondcomponent_noresamp.nii';
spm_write_vol(header2,volume);

