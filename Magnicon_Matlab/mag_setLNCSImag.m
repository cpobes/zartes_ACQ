function out=mag_setLNCSImag(s,IuA)
%Función para fijar valor de Ibias de la LNCS!!!

Ilimite=1.5e3;%%%OJO!!!
if abs(IuA)>Ilimite  %%%Protección para no pasarse.
    error('Ibias too high');
end

% R=218.679249;%%%CH3.LNCS!!! MAL
% DAC=dec2hex(round(((16384*IuA*R)/(10.934*1e6))+8192),4);

R=600;
DAC=dec2hex(round(((16385*IuA*R)/(30.005*1e6))+8192),4);
range='0';

str=sprintf('%s%s%s','<03q0',DAC,range);%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');

if strcmp(out,'|0AC')
    out='OK';
else
    out='FAIL';
end