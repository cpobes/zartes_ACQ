function out=mag_setAutoResetON_CH(s,THR,nch)
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
%dec2hex(round(THR/10.24*128))  %10.08V=125(7Dhex)
%ojo porque 80hex da error. Limitamos a 7Fhex(que da igualmente 10.24V.
%el step de DV es de 0.08V.
thrstr=sprintf('%02X',min(round(THR/10.24*128),hex2dec('7F')));
modestr=strcat('27D',thrstr,'01001');%7Dhex=10.08 para el overload.
str=sprintf('%s%s%s%s','<0',ch,'w7',modestr);%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s')

if strcmp(out,'|0AC')
    out='OK';
else
    out='FAIL';
end