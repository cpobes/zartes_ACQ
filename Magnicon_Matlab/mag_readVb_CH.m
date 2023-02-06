function Vb=mag_readVb_CH(s,nch)
%Funcion para leer Vb

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s','<0',ch,'f8');%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');

%str=sprintf('%s\r','<01q846');
%out=query(s,str,'%s','%s');

dac=hex2dec(out(2:4));

Vb=2.5*dac*1e6/(4096*1470);