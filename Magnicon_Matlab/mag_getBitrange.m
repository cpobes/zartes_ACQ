function range=mag_getBitrange(s)
%Funcion que devuelve el Ibias range en formato double

str=sprintf('%s\r','<01q846');
out=query(s,str,'%s','%s');

%rango info en bit '6'.
range=str2double(out(6));