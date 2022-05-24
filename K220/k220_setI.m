function k220_setI(k220,Ivalue)
%%% Función para fijar el valor de corriente de la fuente. Se pasa como
%%% double en Amperios. Se fija un Imax por precaución por si se pasa por
%%% error un valor demasiado alto.
Imax= 20e-3;
if abs(Ivalue)>Imax
    error('Cuidado, Ivalue demasiado alto');
end
%query(k220,'*CLS\n');
%query(k220,'*RST\n');
%query(k220,'*WAI\n');
str=strcat('I',num2str(Ivalue*1e6),'e-6X','\n');
fwrite(k220,str);
iaux=k220_readI(k220);
if abs(Ivalue-iaux)>1e-6, error('Error Fijando la corriente');end