function range=mag_getIrange_CH(s,nch)
%Funcion para leer el rango de corriente

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

if strcmp(out(6),'0')
    range='125uA';
elseif strcmp(out(6),'1')
    range='500uA';
end