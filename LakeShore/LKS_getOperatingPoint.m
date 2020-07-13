function Tset=LKS_getOperatingPoint(lks,output)
%%%%Función para leer el punto de operación en Kelvin.

if output>=1 & output<=4
else
    error('wrong output number');
end

str=strcat('setp? ',num2str(output),'\n');
%query(lks,str);%%%Como no hay nada que devolver, el query espera hasta el
%timeout.
Tset=str2num(query(lks,str));%%%Usando fprintf eliminamos la espera.
%%%Falta chequer, pero puede tardar unos segundos en estabilizar.