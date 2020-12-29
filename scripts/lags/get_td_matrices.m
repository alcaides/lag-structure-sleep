function get_td_matrices()
% =========================================================================
% get_td_matrices - reads subsampled data and calculate lag matrices.
% Syntax: get_td_matrices

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

component = 'firstcomponent'; % first/secondcomponent;
% component = 'secondcomponent'; % first/secondcomponent;

MAIN_DIRECTORY  = 'C:\pablob_temp';


NSess = 55;

for iSess = 47:48
    
    tic
    fprintf('Sleep data loading(%d/%d)\n',iSess,NSess)
    
    directoryIn = fullfile(MAIN_DIRECTORY,'results/lags/matrixSession',component);
    cd(directoryIn)
    
    Mt = load ([component sprintf('_data_matrix_%02d',iSess)]);
    timeDelay = nan(size(Mt,1),size(Mt,1));
    
    t0xcov=size(Mt,2);
    for voxeli=1:size(Mt,1)
        if not(mod(voxeli,500)),disp(voxeli);end
        
        iSeries = Mt(voxeli,:);
        parfor voxelj=1:voxeli
            timeDelay(voxeli,voxelj) =  calculaTD(Mt,iSeries,voxelj,t0xcov);
        end
    end
    toc
    
    directoryOut = fullfile(MAIN_DIRECTORY,'results/lags/TD',component);
    if not(exist(directoryOut))
        mkdir(directoryOut)
    end
    cd(directoryOut)
    save([component, '_TD_',sprintf('%02.0f',iSess),'.mat'],'timeDelay','-v7.3')
end

end

% -----------------------------------------------------%

function timeDelay = calculaTD(Mt,iSeries,voxelj,t0xcov)

jSeries        = Mt(voxelj,:);
voxelxcov      = xcov(iSeries,jSeries,'biased');

maximosxcov    = max(abs(voxelxcov));
lagmaximosxcov = find(abs(voxelxcov) == maximosxcov,1,'first');

p1 = lagmaximosxcov;

if (p1 == 1) || (p1 == length(voxelxcov))
    timeDelay = nan;
else
    x           = [p1-1 p1 p1+1];
    y           = [voxelxcov(p1-1) voxelxcov(p1) voxelxcov(p1+1)];
    coef        = polyfit(x-p1,y,2);
    xmax        = -coef(2) / ( 2 * coef(1) );
    ymax        = coef(1) * (xmax^2) + coef(2) * xmax + coef(3);
    lagraw      = p1 + xmax;
    maxraw      = ymax;
    timeDelay   = (lagraw - t0xcov) * 3; %lag in seconds
    
    if abs(timeDelay) >= t0xcov  % max possible value, lag estimation has failed
        timeDelay = nan;
    end
end
end
