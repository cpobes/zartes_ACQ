function out=mag_info_CH(s,nch)
%Funcion para obtener el string de info de la electronica (ver manual para significado)

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s','<0',ch,'T8');%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');

%str=sprintf('%s\r','<01T829');
%out=query(s,str,'%s','%s')