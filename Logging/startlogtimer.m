%path='C:\Documents and Settings\Usuario\Escritorio\Datos\Sept2015\'
%logfile=IGH-log;
T=timer
T.TimerFcn='tmp=importdata(strcat(path,logfile));'
T.ExecutionMode='FixedRate'
T.Period=30
start(T)