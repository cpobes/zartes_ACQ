%%%start Timers

if isempty(who('datadir'))
    error('define el directorio de datos como datadir')
end

if exist(strcat(datadir,'\Pivc.mat'))==2
    load strcat(datadir,'\Pivc.mat')
end

if exist(strcat(datadir,'\HeLevel.mat'))==2
    load strcat(datadir,'\HeLevel.mat')
end

startHeLtimer
startIVCtimer 
