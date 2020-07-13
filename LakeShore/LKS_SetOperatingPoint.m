function LKS_SetOperatingPoint(lks,output,Temperature)
%%%%Función que fija el Punto de operación en Kelvin.

if output>=1 & output<=4
else
    error('wrong output number');
end

str=strcat('setp ',num2str(output),',',num2str(Temperature),'\n');
%query(lks,str);%%%Como no hay nada que devolver, el query espera hasta el
%timeout.
fprintf(lks,str);%%%Usando fprintf eliminamos la espera.
%%%Falta chequer, pero puede tardar unos segundos en estabilizar.