function out=mag_setFLL(s)
%Funcion para poner modo FLL
%Ojo, solo Ch1.

str=sprintf('%s\r','<01b0160');
out=query(s,str,'%s','%s');

if strcmp(out,'|0AC')
    out='OK';
else
    out='FAIL';
end