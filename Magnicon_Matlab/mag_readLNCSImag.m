function IuA=mag_readLNCSImag(s)
%Funcion para leer la Ibias de la LNCS!

str=sprintf('%s\r','<03q848');
out=query(s,str,'%s','%s');

dac=hex2dec(out(2:5));

% R=218.679249;%%%Para rango 25mA! MAL
% IuA=(10.934*(dac-8192)*1e6)/(16384*R);

R=600;
IuA=(30.005*(dac-8192)*1e6)/(16385*R);