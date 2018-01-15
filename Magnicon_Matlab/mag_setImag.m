function out=mag_setImag(s,IuA)
%Función para fijar valor de Ibias. Pasar Ibias en uA.

if abs(IuA)>500
    error('Ibias too high');
end
if abs(IuA)>125
    mag_setIrange(s,'500');
end

if mag_getBitrange(s)
    R=10895;%R para rango 500uA (bit:1)
    range='1';
else
    R=43600;%R para rango 125uA (bit:0)
    range='0';
end

%R=218.679249;%%%CH3.LNCS!!!
DAC=dec2hex(round(((16384*IuA*R)/(10.934*1e6))+8192),4);%%%ch1


str=sprintf('%s%s%s','<01q0',DAC,range);%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');

if strcmp(out,'|0AC')
    out='OK';
else
    out='FAIL';
end