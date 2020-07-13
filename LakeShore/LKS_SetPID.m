function PID=LKS_SetPID(lks,output,PID)
%%%%Función que fija el PID de un output determinado
%%%v0:toma vector con la forma PID=[P I D];

if output>=1 & output<=4
else
    error('wrong output number');
end

str=strcat('PID ',num2str(output),',',num2str(PID(1)),',',num2str(PID(2)),',',num2str(PID(3)),',','\n');
%query(lks,str);%%%Como no hay nada que devolver, el query espera hasta el
%timeout.
fprintf(lks,str);%%%Usando fprintf eliminamos la espera.
setpid=LKS_getPID(lks,output);
if sum(setpid-PID)
    error('PID not correctly set');
end