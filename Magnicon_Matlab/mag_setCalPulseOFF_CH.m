function out=mag_setCalPulseOFF_CH(s,nch)
%Funcion para fijar el rango de duración del pulso de calibracion.
% pasamos el modo en formato numérico mode=1 '<150us'; mode=2 '>=150us';

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s','<0',ch,'P8');%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');

out(13)=num2str(0);

str=sprintf('%s%s%s%s','<0',ch,'P0',out(2:end-2));%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');