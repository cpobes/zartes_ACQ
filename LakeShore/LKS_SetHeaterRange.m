function LKS_SetHeaterRange(lks,output,Range)
%%%%Función que fija el rango del heater (0->5)
%%% range=0 para OFF.
if output>=1 & output<=4
else
    error('wrong output number');
end

str=strcat('range ',num2str(output),',',num2str(Range),'\n');
%query(lks,str);%%%Como no hay nada que devolver, el query espera hasta el
%timeout.
fprintf(lks,str);%%%Usando fprintf eliminamos la espera.
%%%Falta chequer, pero puede tardar unos segundos en estabilizar.