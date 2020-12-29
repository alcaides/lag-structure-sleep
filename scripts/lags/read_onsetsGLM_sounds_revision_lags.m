function read_onsetsGLM_sounds()
% =========================================================================
%read_onsets.m - reads h5 files and saves useful events' info
% Extracts onset and duration of events of interest. Those are:
%
% sleepOnset: sleep blocks onset
% awakeOnset: awake blocks onset
% sleepLenght: sleep blocks duration
% awakeLenght: awake blocks duration
%
% Syntax:  just read_onsets
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Authors: Santiago Alcaide and Pablo Barttfeld
% Cognitive Sciences Group, Cordoba Argentina
% email: santiago_asa@gmail.com
% cognitivas.github.io
% Nov-201934
% =========================================================================
clear
MAIN_DIRECTORY = '/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro';

after_onset = 20;

nSubjects   = 3;

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
        
        dataOnsets.sub(iSub).sess(iSess).wakingUpOnset(1,1) = 0;
        
        iWakeUp =1;
        for jScan =1:ndata-1             %Sleep reference: sleep = 0 ; awake = 1
            
            deriv = dataOnsets.sub(iSub).sess(iSess).sleep(jScan) ...
                - dataOnsets.sub(iSub).sess(iSess).sleep(jScan + 1);
            
            switch deriv
                
                case -1 %Sleep to awake transition
                    
                    % if confirmed by EEG. Coming from sleep 1 or 2; going to nan or 0
                    condition1 = (dataOnsets.sub(iSub).sess(iSess).EEGstage(jScan) == 1) || ...
                        (dataOnsets.sub(iSub).sess(iSess).EEGstage(jScan) == 2);
                    
                    condition2 = (isnan(dataOnsets.sub(iSub).sess(iSess).EEGstage(jScan + 1))) || ...
                        (dataOnsets.sub(iSub).sess(iSess).EEGstage(jScan + 1) == 0);
                    
                    if condition1 && condition2
                        
                        ts  = dataOnsets.sub(iSub).sess(iSess).EEGstage(jScan+1:end);
                        ts2 = isnan(ts) | ts == 0;
                        d   = diff(ts2);
                        f   = find(not(d==0),1);
                        
                        if isempty(find(not(d==0), 1)) % last one
                            dataOnsets.sub(iSub).sess(iSess).wakingUpOnset(iWakeUp,1)   = jScan;
                            iWakeUp = iWakeUp + 1;
                            
                        elseif f >= after_onset % 20 or more NaN after wake up, for a total of 21 scans (including the waking up one
                            dataOnsets.sub(iSub).sess(iSess).wakingUpOnset(iWakeUp,1)   = jScan;
                            iWakeUp = iWakeUp + 1;
                        end
                    end
            end
        end
        
    end
end

cd(fullfile(MAIN_DIRECTORY,'data'))
save dataOnsets_lags dataOnsets



