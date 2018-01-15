function duration=mag_getCalPulseDuration_CH(s,nch)
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
out=query(s,str,'%s','%s');

%str=sprintf('%s\r','<01q846');
%out=query(s,str,'%s','%s');

%rango info en bit '6'.
DAC=hex2dec(out(3:4))
%mode=mag_getCalPulseDurationMode_CH(s,nch);
mode=str2num(out(2))
if mode==1
   d=2500/9;%277.7777
elseif mode==2
    d=20000/9; %2222.22222
end

duration=d*(DAC-2)/255;

