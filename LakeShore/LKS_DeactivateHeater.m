function LKS_DeactivateHeater(lks,output)
%%%%Función que desactiva el heater.
if output>=1 && output<=4
else
    error('wrong output number');
end

str=strcat('outmode ',num2str(output),',','0,1,1','\n');%%%Desactivamos el Closed Loop.
fprintf(lks,str);%%%Usando fprintf eliminamos la espera.
str=strcat('range ',num2str(output),',','0','\n');%%%Desactivamos el Rango.
fprintf(lks,str)
%%%Falta chequer, pero puede tardar unos segundos en estabilizar.