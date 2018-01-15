function Rf=mag_readRf_FLL_CH(s,nch)
%%%funcion para leer el valor de Rf en lazo cerrado.

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s','<0',ch,'n9');%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');

%str=sprintf('%s\r','<01n944');
%out=query(s,str,'%s','%s');

table=[0 0.7 0.75 0.91 1 2.14 2.31 2.73 3.0 7.0 7.5 9.1 10 23.1 30 100]*1e3;
ind=hex2dec(out(2))+1;
Rf=table(ind);