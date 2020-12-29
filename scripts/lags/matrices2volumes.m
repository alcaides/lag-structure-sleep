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

component = 'firstcomponent'; % first/secondcomponent;
% component = 'secondcomponent'; % first/secondcomponent;

maxSession = 55;

directoryIn = fullfile(MAIN_DIRECTORY,'data/Analyze_data',['subject',num2str(1)],...
    ['SleepDataSubject',num2str(1),'Session',sprintf('%0.2i', 1)],...
    ['swImagesSub',sprintf('%0.2i', 1),'session',sprintf('%0.2i', 1),'CovariatesOut']);

cd(directoryIn)
images  = dir('r0*.nii');

header2 = spm_vol(images(1).name);

header  = spm_vol(fullfile(MAIN_DIRECTORY,'scripts/lags','rmascara.img'));
mask    = logical(spm_read_vols(header));

for iSub = 1:maxSession
    
    cd (fullfile(MAIN_DIRECTORY,'results/lags/TD',component));
    
    fprintf('working on matrix %d out of %d\n', iSub,maxSession)
    
    averageTD = load(sprintf([component,'_TD_%02d'],iSub));
    
    averageTD.timeDelay = tril(averageTD.timeDelay);
    M = averageTD.timeDelay - averageTD.timeDelay';
    
    
    M = averageTD.timeDelay -averageTD.timeDelay';
    
    volume = zeros(size(mask));
    volume(mask) = nanmean(M,2);
    
    header2.fname = [component, sprintf('_%02.0f',iSub),'.nii'];
    if not(exist(fullfile(MAIN_DIRECTORY,'results/lags/TD',component,'volumes')))
        mkdir(fullfile(MAIN_DIRECTORY,'results/lags/TD',component,'volumes'))
    end
  
    cd(fullfile(MAIN_DIRECTORY,'results/lags/TD',component,'volumes'))
    spm_write_vol(header2,volume);
end


