function out=mag_info(s)
%Funcion para obtener el string de info de la electronica (ver manual para significado)
%Ojo, solo Ch1.

str=sprintf('%s\r','<01T829');
out=query(s,str,'%s','%s')