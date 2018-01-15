function out=mag_setCalPulseDuration_CH(s,duration,nch)
%Funcion para leer el rango de duración del pulso de calibracion.
% usamos formato numérico: mode=1 '<150us'; mode=2 '>=150us';
% duration en us!!!
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
if duration<1.09
    duration=1.09;
end
if duration>2000
    duration=2000;
end
if duration<150
    d=2500/9;
    out(2)=num2str(1);
elseif duration>=150
    d=20000/9;
    out(2)=num2str(2);
end

%
DAC=duration*255/d+2;
DAC_hex=dec2hex(round(DAC),2);
out(3:4)=DAC_hex;

str=sprintf('%s%s%s%s','<0',ch,'P0',out(2:end-2));%%%El \r no se cuenta.
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');