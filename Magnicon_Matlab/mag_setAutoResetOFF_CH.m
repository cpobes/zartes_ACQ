function out=mag_setAutoResetOFF_CH(s,nch)
%Función para poner on/off el autoreset

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end
%%%
%#1:mode(0:off,1:ovl,2:ar,3:dfc)
%#2-3:ovlTHR
%#4-5:arTHR
%#6-7:dfcTHR
%#8-10:dfc-step
modestr='0010101001';
str=sprintf('%s%s%s%s','<0',ch,'w7',modestr);%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s')

if strcmp(out,'|0AC')
    out='OK';
else
    out='FAIL';
end