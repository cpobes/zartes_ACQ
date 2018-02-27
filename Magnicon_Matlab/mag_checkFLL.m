function mode=mag_checkFLL(s)
%funcion para preguntar estado. 
%Ojo, solo Ch1.

str=sprintf('%s\r','<01b837');
mode=query(s,str,'%s','%s');

if strcmp(mode,'>16F')
    mode='FLL mode';
elseif strcmp(mode,'>06E')
    mode='AMP mode';
else
    mode='error';
end