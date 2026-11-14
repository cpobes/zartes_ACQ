function LKS_SetOperatingPoint(lks,output,Temperature)
%%%%Función que fija el Punto de operación en Kelvin.
%%%Modified for model 372.

if output>=1 && output<=4
    error('Old 350 model');
elseif output==0
    %error('wrong output number');
end

str=['setp' num2str(output)  sprintf('+%dE0',Temperature) '\n'];%reformated para modelo 372.
%query(lks,str);%%%Como no hay nada que devolver, el query espera hasta el
%timeout.
fprintf(lks,str);%%%Usando fprintf eliminamos la espera.
%%%Falta chequer, pero puede tardar unos segundos en estabilizar.