function reslice_for_lags()
% =========================================================================
% =========================================================================
clc

MAIN_DIRECTORY  = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';


voxelSize= [5 5 5]; % new voxel size {mm}

nSubjects = 3;


for iSub = 1:nSubjects
    
    fprintf('Read data for Subject %d\n',iSub);
    
    
    switch iSub    % defines session number for each subject
        case 1
            nSleepDataSession = 26;
        case 2
            nSleepDataSession = 14;
        case 3
            nSleepDataSession = 15;
        otherwise
            error('incorrect subject number');
    end
    
    for iSess = 1:nSleepDataSession
        fprintf('Sleep data loading (%d/%d)\n',iSess,nSleepDataSession)
        
        folder = fullfile(MAIN_DIRECTORY,'data/Analyze_data',['subject',num2str(iSub)],...
            ['SleepDataSubject',num2str(iSub),'Session',sprintf('%0.2i', iSess)],...
            ['swImagesSub',sprintf('%0.2i', iSub),'session',sprintf('%0.2i', iSess),'CovariatesOut']);
        cd(folder)
        
        
        V = spm_select('list',pwd,'^0.*\.nii$');
        V = spm_vol(V);
        
        for iImage=1:numel(V)
            bb        = spm_get_bbox(V(iImage));
            VV(1:2)   = V(iImage);
            VV(1).mat = spm_matrix([bb(1,:) 0 0 0 voxelSize])*spm_matrix([-1 -1 -1]);
            VV(1).dim = ceil(VV(1).mat \ [bb(2,:) 1]' - 0.1)';
            VV(1).dim = VV(1).dim(1:3);
            spm_reslice(VV,struct('mean',false,'which',2,'interp',1));
        end
        
    end
end
        
        
        
        
        