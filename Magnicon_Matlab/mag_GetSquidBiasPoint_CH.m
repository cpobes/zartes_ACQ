function SquidBiasPoint=mag_GetSquidBiasPoint_CH(s,nch)
%%%Funcion para leer el punto de polarización del Squid.
if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end
SquidBiasPoint.Ch=ch;
SquidBiasPoint.Ib=mag_readIb_CH(s,nch);
SquidBiasPoint.Vb=mag_readVb_CH(s,nch);
SquidBiasPoint.Phib=mag_readPhib_CH(s,nch);