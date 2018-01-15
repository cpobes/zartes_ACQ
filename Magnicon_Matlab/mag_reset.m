function out=mag_reset(s)
%Funcion para enviar un reset a la electrinica
%Ojo, solo Ch1.

str=sprintf('%s\r','<01Z027');
out=query(s,str,'%s','%s');

if strcmp(out,'|0AC')
    out='OK';
else
    out='FAIL';
end