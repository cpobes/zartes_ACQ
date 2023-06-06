function Counters=mag_readOverloadCounters_CH(s,nch)
%Función para poner on/off el autoreset

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s','<0',ch,'w9');%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');

Counters.OvlP=hex2dec(out(2:5));
Counters.OvlN=hex2dec(out(6:9));
Counters.ARP=hex2dec(out(10:13));
Counters.ARN=hex2dec(out(14:17));
Counters.DFCP=hex2dec(out(18:21));
Counters.DFCN=hex2dec(out(22:25));