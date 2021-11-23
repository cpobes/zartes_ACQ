function IuA=mag_readImag_CH(s,nch)
%Funcion para leer la Ibias

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s','<0',ch,'q8');%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');

%str=sprintf('%s\r','<01q846');
%out=query(s,str,'%s','%s');

dac=hex2dec(out(2:5));

if mag_getBitrange_CH(s,nch)
    R=10895;%R para rango 500uA (bit:1)
else
    R=43600;%R para rango 125uA (bit:0)
end

%R=218.679249;%%%Para rango 25mA!
IuA=(10.934*(dac-8192)*1e6)/(16384*R);
%%% I STEP: 61.2536nA (rango 500uA) 15.3064nA (rango 125uA).
