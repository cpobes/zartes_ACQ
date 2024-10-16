function out=mag_setImag_CH(s,IuA,nch)
%Funci�n para fijar valor de Ibias. Pasar Ibias en uA.
% %dac=0 corresponde a Ibias:-501.7898118402937
% fijando Ib=-500 corresponde a dac=29.

Imax=500.02;%Al poner 500 en la fte se ponen realmente 500.013uA.
if abs(IuA)>Imax
    error('Ibias too high');
end
if abs(IuA)>125
    mag_setIrange_CH(s,'500',nch);
end

if mag_getBitrange_CH(s,nch)
    R=10895;%R para rango 500uA (bit:1)
    range='1';
else
    R=43600;%R para rango 125uA (bit:0)
    range='0';
end

%R=218.679249;%%%CH3.LNCS!!!
DAC=dec2hex(round(((16384*IuA*R)/(10.934*1e6))+8192),4);%%%ch1

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s%s%s','<0',ch,'q0',DAC,range);%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');

if strcmp(out,'|0AC')
    out='OK';
else
    out='FAIL';
end