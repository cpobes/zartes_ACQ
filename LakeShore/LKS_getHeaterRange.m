function HtrRange=LKS_getHeaterRange(lks,output)
%%%%Función que fija el rango del heater (0->5)
%%% range=0 para OFF.
if output>=1 & output<=4
else
    error('wrong output number');
end

str=strcat('range? ',num2str(output),'\n');
%query(lks,str);%%%Como no hay nada que devolver, el query espera hasta el
%timeout.
HtrRange=query(lks,str);
%%%Falta chequer, pero puede tardar unos segundos en estabilizar.