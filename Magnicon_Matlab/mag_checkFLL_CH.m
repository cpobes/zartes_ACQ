function mode=mag_checkFLL_CH(s,nch)
%funcion para preguntar estado. 

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s','<0',ch,'b8');%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
mode=query(s,str,'%s','%s');

%str=sprintf('%s\r','<01b837');
%mode=query(s,str,'%s','%s');

if strcmp(mode,'>16F')
    mode='FFL mode';
elseif strcmp(mode,'>06E')
    mode='AMP mode';
else
    mode='error';
end