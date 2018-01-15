function out=mag_getSwitchState_CH(s,nch)
%Funcion para leer el rango de duración del pulso de calibracion.
% usamos formato numérico: mode=1 '<150us'; mode=2 '>=150us';

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s','<0',ch,'a8');%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');