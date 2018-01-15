function IuA=mag_readImag(s)
%Funcion para leer la Ibias

str=sprintf('%s\r','<01q846');
out=query(s,str,'%s','%s');

dac=hex2dec(out(2:5));

if mag_getBitrange(s)
    R=10895;%R para rango 500uA (bit:1)
else
    R=43600;%R para rango 125uA (bit:0)
end

%R=218.679249;%%%Para rango 25mA!
IuA=(10.934*(dac-8192)*1e6)/(16384*R);