function reslice_for_lags_rois()
% =========================================================================
% =========================================================================
clc
clear
MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';


voxelSize= [5 5 5]; % new voxel size {mm}

% folder = fullfile(MAIN_DIRECTORY,'results','GLM/rois/roisFWE005/');
folder = '/home/pablo/Escritorio/rois'
cd(folder)

V = spm_select('list',pwd,'^.*\.img$');
V = spm_vol(V);

for iImage=1:numel(V)
    bb        = spm_get_bbox(V(iImage));
    VV(1:2)   = V(iImage);
    VV(1).mat = spm_matrix([bb(1,:) 0 0 0 voxelSize])*spm_matrix([-1 -1 -1]);
    VV(1).dim = ceil(VV(1).mat \ [bb(2,:) 1]' - 0.1)';
    VV(1).dim = VV(1).dim(1:3);
    spm_reslice(VV,struct('mean',false,'which',2,'interp',1));
end


