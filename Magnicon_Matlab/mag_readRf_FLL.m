function Rf=mag_readRf_FLL(s)
%%%funcion para leer el valor de Rf en lazo cerrado.

str=sprintf('%s\r','<01n944');
out=query(s,str,'%s','%s');

table=[0 0.7 0.75 0.91 1 2.14 2.31 2.73 3.0 7.0 7.5 9.1 10 23.1 30 100]*1e3;
ind=hex2dec(out(2))+1;
Rf=table(ind);