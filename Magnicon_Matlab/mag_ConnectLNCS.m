function out=mag_ConnectLNCS(s)
%%%Funcion para conectar la LNCS source

str=sprintf('%s\r','<03a838');%%comando para leer el switch del ch3.
out=query(s,str,'%s','%s');

dac=hex2dec(out(2:5));

new=dec2hex(bitand(dac,65279),4) %%%El bit para desconectar es el 1º del 2º char.
%%%65279=hex2dec('FEFF')

str=sprintf('%s%s','<03a0',new);%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');