function k220_setI(k220,Ivalue)
%%% Función para fijar el valor de corriente de la fuente. Se pasa como
%%% double en Amperios. Se fija un Imax por precaución por si se pasa por
%%% error un valor demasiado alto.
Imax= 0.005;
if Ivalue>Imax
    error('Cuidado, Ivalue demasiado alto');
end
str=strcat('I',num2str(Ivalue),'X','\n')
query(k220,str)