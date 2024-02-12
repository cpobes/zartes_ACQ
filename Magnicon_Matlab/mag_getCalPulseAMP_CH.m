function AMP=mag_getCalPulseAMP_CH(s,RL,nch)
%Funcion para fijar el rango de duración del pulso de calibracion.
% pasamos el modo en formato numérico mode=1 '<150us'; mode=2 '>=150us';

%%Ojo, RL se pasa como parámetro. No hay forma de verificar que sea el
%%correcto.

if nch==1
    ch='1';
elseif nch==2
    ch='2';
else
    error('wrong Channel number');
end

str=sprintf('%s%s%s','<0',ch,'r8');%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');

DAC=hex2dec(out(2:4));

if RL==0
AMP=5e6*(DAC-2048)/(4096*1.0196*20000);
else
    I=mag_readImag_CH(s,nch)*1e-6;
    Rp=(RL^-1+22143^-1)^-1;
    Upa=5e6*(DAC-2048)/4096;%%%error en manual? 1e6.
    range=mag_getIrange_CH(s,nch);
        if strcmp(range,'125uA')
            R=43600;
        elseif strcmp(range,'500uA')
            R=10895;
        end
    Ui=I*Rp/(Rp+R);
    K=RL^-1+R^-1+20000^-1;
    AMP=(Ui/R+Upa/20228)/(RL*K)-I*1e6;
end