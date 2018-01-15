function out=mag_setCalPulseDT_CH(s,DT,nch)
%Funcion para fijar el rango de duración del pulso de calibracion.
% pasamos el modo en formato numérico mode=1 '<150us'; mode=2 '>=150us';
%OJO: DT en ms!!!

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

DAC=(DT*1000-10)/95.5;
if DAC>65535
    DAC=65535;%%%limite 'FFFF'
end
DAC_hex=dec2hex(round(DAC),4);
out(5:8)=DAC_hex;

str=sprintf('%s%s%s%s','<0',ch,'P0',out(2:end-2));%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');
mode=mag_getCalPulseDurationMode_CH(s,nch);