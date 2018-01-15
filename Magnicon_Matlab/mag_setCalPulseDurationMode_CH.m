function out=mag_setCalPulseDurationMode_CH(s,mode,nch)
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

%str=sprintf('%s\r','<01q846');
%out=query(s,str,'%s','%s');

%mode=1 '<150us'; mode=2 '>=150us';
%En modo=1 el DAC_max='8C'=140.
%En modo=2 el DAC_max='E8'=230.
if mode==1 && hex2dec(out(3:4))>140
    warning('no se ha podido cambiar el modo');
    return;
end
out(2)=num2str(mode)

str=sprintf('%s%s%s%s','<0',ch,'P0',out(2:end-2));%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');
mode=mag_getCalPulseDurationMode_CH(s,nch);
% if mode==1
%     sprintf('CAL Pulse Mode set to: %s','<150us')
% elseif mode==2
%     sprintf('CAL Pulse Mode set to: %s','>=150us')
% end
    