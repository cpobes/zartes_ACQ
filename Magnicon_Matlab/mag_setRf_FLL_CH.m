function out=mag_setRf_FLL_CH(s,Rf,nch)
%%%Funcion para fijar un valor de Rf en FLL. Redondea al valor de tabla más
%%%cercano.
table=[0 0.7 0.75 0.91 1 2.14 2.31 2.73 3.0 7.0 7.5 9.1 10 23.1 30 100]*1e3;
ind=find(abs(table-Rf)==min(abs(table-Rf)));

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s%X','<0',ch,'n1',ind(1)-1);
chk=mod(sum(double(str)),256);
str=sprintf('%s%X\r',str,chk);
out=query(s,str,'%s','%s');
aux=mag_readRf_FLL_CH(s,nch);
sprintf('Rf set to: %d Ohm',aux)