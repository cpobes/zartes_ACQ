function out=mag_setAMP(s)
%Funcion para poner modo AMP
%Ojo, solo Ch1.

str=sprintf('%s\r','<01b005F');
out=query(s,str,'%s','%s');

if strcmp(out,'|0AC')
    out='OK';
else
    out='FAIL';
end