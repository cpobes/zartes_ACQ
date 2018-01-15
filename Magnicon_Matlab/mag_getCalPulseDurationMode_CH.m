function mode=mag_getCalPulseDurationMode_CH(s,nch)
%Funcion para leer el rango de duración del pulso de calibracion.
% usamos formato numérico: mode=1 '<150us'; mode=2 '>=150us';

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
out=query(s,str,'%s','%s')

%str=sprintf('%s\r','<01q846');
%out=query(s,str,'%s','%s');

%rango info en bit '6'.
mode=str2double(out(2));

if mode==1
    sprintf('CAL Pulse Mode set to: %s','<150us')
elseif mode==2
    sprintf('CAL Pulse Mode set to: %s','>=150us')
end