function out=mag_DisconnectLNCS(s)
%%%Funcion para desconectar la LNCS source

str=sprintf('%s\r','<03a838');%%comando para leer el switch del ch3.
out=query(s,str,'%s','%s');

dac=hex2dec(out(2:5));

new=dec2hex(bitor(dac,256),4); %%%El bit para desconectar es el 1� del 2� char.

str=sprintf('%s%s','<03a0',new);%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');