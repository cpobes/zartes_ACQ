function HtrSet=LKS_readHeaterPercentage(lks,output)
%%%%Función para leer el porcentaje de excitación del heater.

if output>=1 & output<=4
else
    error('wrong output number');
end

str=strcat('htr? ',num2str(output),'\n');
%query(lks,str);%%%Como no hay nada que devolver, el query espera hasta el
%timeout.
HtrSet=str2num(query(lks,str));%%%Usando fprintf eliminamos la espera.
%%%Falta chequer, pero puede tardar unos segundos en estabilizar.