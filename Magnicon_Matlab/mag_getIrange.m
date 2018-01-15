function range=mag_getIrange(s)
%Funcion para leer el rango de corriente

str=sprintf('%s\r','<01q846');
out=query(s,str,'%s','%s');
if strcmp(out(6),'0')
    range='125uA';
elseif strcmp(out(6),'1')
    range='500uA';
end