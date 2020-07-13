function PID=LKS_getPID(lks,output)
%%%%Función que devuelve el PID de un output determinado
%%%v0:devuelve un vector con PID=[P I D];

if output>=1 & output<=4
else
    error('wrong output number');
end
str=strcat('PID? ',num2str(output),'\n')
PID=query(lks,str);
PID=str2num(PID);