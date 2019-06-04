function out=mag_setPhib_CH(s,IuA,nch)
%Función para fijar valor de Phi_b. Pasar Ibias en uA.


DAC=dec2hex(round(IuA*4096*20071/5e6+2048),3);%%%

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s%s','<0',ch,'j0',DAC);%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');

if strcmp(out,'|0AC')
    out='OK';
else
    out='FAIL';
end