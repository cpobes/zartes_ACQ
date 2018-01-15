function out=mag_setFLL_CH(s,nch)
%Funcion para poner modo FLL

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s','<0',ch,'b01');%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');

%str=sprintf('%s\r','<01b0160');
%out=query(s,str,'%s','%s');

if strcmp(out,'|0AC')
    out='OK';
else
    out='FAIL';
end