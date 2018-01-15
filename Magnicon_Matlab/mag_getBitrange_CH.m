function range=mag_getBitrange_CH(s,nch)
%Funcion que devuelve el Ibias range en formato double

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

%rango info en bit '6'.
range=str2double(out(6));