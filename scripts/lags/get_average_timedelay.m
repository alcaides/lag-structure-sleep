clear
cd D:\pablo_temp\lags\TD_noresamp\firstcomponent
load firstcomponent_TD_noresamp.mat

% max(max(timeDelay));
% min(min(timeDelay));

t = tril(timeDelay);
t = t - t';
firstc = nanmean(t,2);
save firstc firstc

clear
cd D:\pablo_temp\lags\TD_noresamp\secondcomponent
load secondcomponent_TD_noresamp.mat

% max(max(timeDelay));
% min(min(timeDelay));


t = tril(timeDelay);
t = t - t';
secondc = nanmean(t,2);
save secondc secondc



