function out=mag_setIrange_CH(s,rango,nch)
%Funcion para poner el rango de corriente.

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

if ~isempty(strfind(rango,'125'))
    out(6)='0';
elseif ~isempty(strfind(rango,'500'))
    out(6)='1';
end

str=sprintf('%s%s%s%s','<0',ch,'q0',out(2:6));
chk=mod(sum(double(str)),256);
str=sprintf('%s%X\r',str,chk);
out=query(s,str,'%s','%s');

if strcmp(out,'|0AC')
    out='OK';
else
    out='FAIL';
end