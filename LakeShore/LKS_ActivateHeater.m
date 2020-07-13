function LKS_ActivateHeater(lks,output,Range)
%%%%Función que fija el rango del heater (0->5)
%%% range=0 para OFF.
if output>=1 & output<=4
else
    error('wrong output number');
end

str=strcat('outmode ',num2str(output),',','1,1,1','\n');%%%Activamos el Closed Loop.
fprintf(lks,str);%%%Usando fprintf eliminamos la espera.
str=strcat('range ',num2str(output),',',num2str(Range),'\n');%%%Activamos el Rango.
fprintf(lks,str)
%%%Falta chequer, pero puede tardar unos segundos en estabilizar.