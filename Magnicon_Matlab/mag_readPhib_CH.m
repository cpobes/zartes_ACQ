function IuA=mag_readPhib_CH(s,nch)
%Funcion para leer la Ibias

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s','<0',ch,'j8');%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk)
out=query(s,str,'%s','%s')

%str=sprintf('%s\r','<01q846');
%out=query(s,str,'%s','%s');

dac=hex2dec(out(2:4))

IuA=5*(dac-2048)*1e6/(4096*20071);%%%ojo, está mal el manual!!!