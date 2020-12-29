% function read_onsetsGLM_sounds()
% =========================================================================
%read_onsets.m - reads h5 files and saves useful events' info
%
% Authors: Santiago Alcaide and Pablo Barttfeld
% Cognitive Sciences Group, Cordoba Argentina
% email: santiago_asa@gmail.com
% cognitivas.github.io
% Nov-2019
% =========================================================================
clear
MAIN_DIRECTORY = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';

nSubjects = 3;
for iSub = 1:nSubjects
    
    fprintf('Read data for Subject %d\n',iSub);
    switch iSub
        case 1
            maxSess=26;
        case 2
            maxSess=14;
        case 3
            maxSess=15;
        otherwise
            error('incorrect subject number');
    end
    
    
    for iSess = 1:maxSess
        fprintf('Analyzing session (%d/%d)\n',iSess,maxSess);
        
        file = fullfile(MAIN_DIRECTORY,'data/OriginalSleeph5',...
            ['SleepDataSubject',num2str(iSub),'Session',num2str(iSess),'.h5']);
        
        dataOnsets.sub(iSub).sess(iSess).EEGstage = h5read(file,'/group6/data');
        dataOnsets.sub(iSub).sess(iSess).sleep    = h5read(file,'/group2/data');
        
        ndata = numel(dataOnsets.sub(iSub).sess(iSess).sleep); %total amount of files
        iSleep          = 2; %sleepOnset index
        iAwake          = 1; %awakeOnset index
        
        dataOnsets.sub(iSub).sess(iSess).sleepOnset(1,1)    = 1;
        dataOnsets.sub(iSub).sess(iSess).awakeOnset(1,1)    = 0;
        dataOnsets.sub(iSub).sess(iSess).sleepLenght(1,1)   = 0;
        dataOnsets.sub(iSub).sess(iSess).awakeLenght(1,1)   = 0;
        dataOnsets.sub(iSub).sess(iSess).wakingUpOnset(1,1) = 0;
        
        iWakeUp =1;
        for jScan =1:ndata-1             %Sleep reference: sleep = 0 ; awake = 1
            
            deriv = dataOnsets.sub(iSub).sess(iSess).sleep(jScan) ...
                - dataOnsets.sub(iSub).sess(iSess).sleep(jScan + 1);
            
            switch deriv
                case 1 %Awake to sleep transition
                    dataOnsets.sub(iSub).sess(iSess).sleepOnset(iSleep,1)       = jScan + 1;
                    dataOnsets.sub(iSub).sess(iSess).awakeLenght(iAwake-1,1)    = ...
                        (jScan + 1) - dataOnsets.sub(iSub).sess(iSess).awakeOnset(iAwake-1,1);
                    
                    iSleep = iSleep + 1;
                    
                case -1 %Sleep to awake transition
                    
                    
                    % if confirmed by EEG. Coming from sleep 1 or 2; going to nan or 0
                    condition1 = (dataOnsets.sub(iSub).sess(iSess).EEGstage(jScan) == 1) || ...
                                 (dataOnsets.sub(iSub).sess(iSess).EEGstage(jScan) == 2);
                    
                    condition2 = (isnan(dataOnsets.sub(iSub).sess(iSess).EEGstage(jScan + 1))) || ...
                                 (dataOnsets.sub(iSub).sess(iSess).EEGstage(jScan + 1) == 0);
                    
                    if condition1 && condition2
                        dataOnsets.sub(iSub).sess(iSess).wakingUpOnset(iWakeUp,1)    = jScan + 1;
                        iWakeUp = iWakeUp + 1;
                        
                    end
                    dataOnsets.sub(iSub).sess(iSess).awakeOnset(iAwake,1)       = jScan + 1;
                    dataOnsets.sub(iSub).sess(iSess).sleepLenght(iSleep-1,1)    = ...
                        (jScan + 1 )- dataOnsets.sub(iSub).sess(iSess).sleepOnset(iSleep-1,1);
                    
                    iAwake = iAwake + 1;
            end
            
            if jScan == ndata-1
                dataOnsets.sub(iSub).sess(iSess).awakeLenght(iAwake-1,1) = ...
                    jScan + 1 - dataOnsets.sub(iSub).sess(iSess).awakeOnset(iAwake-1,1);
            end
            
        end
        
        if iSub == 3 && ((iSess == 12) || (iSess == 13))
            continue,
        end
        
        load(fullfile(MAIN_DIRECTORY,'data','sound_detection',...
            ['SoundDetection_SleepDataSubject',num2str(iSub),'Session',num2str(iSess),'.mat']))
        
        SoundTimes      = (sd.soundTimes_sec') ./3;
        
        inds            = isnan(sd.respTimes_sec');
        
        RespTimes       = (sd.respTimes_sec(not(inds))') ./3;
        
        SoundTimes_Response     = (sd.soundTimes_sec(not(inds))')./3;
        SoundTimes_NoResponse   = (sd.soundTimes_sec(inds)')./3;
        
        dataOnsets.sub(iSub).sess(iSess).SoundTimes             = SoundTimes;
        dataOnsets.sub(iSub).sess(iSess).RespTimes              = RespTimes;
        dataOnsets.sub(iSub).sess(iSess).SoundTimes_Response    = SoundTimes_Response;
        dataOnsets.sub(iSub).sess(iSess).SoundTimes_NoResponse  = SoundTimes_NoResponse;
        

        
    end
end

cd(fullfile(MAIN_DIRECTORY,'data'))
save dataOnsetsGLM dataOnsets




