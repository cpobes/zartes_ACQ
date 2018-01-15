function out=mag_setCalPulseAMP_CH(s,RL,AMP,nch)
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


if RL==0
    %AMP=5e6*(DAC-2048)/(4096*1.0196*20000);
    DAC=AMP*4096*1.0196*20000/5e6+2048;
    if DAC<0 || DAC>4095
        warning('Amplitud fuera de rango');
        return;
    end
else
    I=mag_readImag_CH(s,nch);
    Rp=(RL^-1+22143^-1)^-1;
    range=mag_getIrange_CH(s,nch);
        if strcmp(range,'125uA')
            R=43600;
        elseif strcmp(range,'500uA')
            R=10895;
        end
    Ui=I*Rp/(Rp+R);
    K=RL^-1+R^-1+20000^-1;
    %Upa=5e6*(DAC-2048)/4096;%%%error en manual? 1e6.
    Upa=((AMP+I)*RL*K-(Ui/R))*20228;
    DAC=Upa*4096/5e6+2048;
end

DAC_hex=dec2hex(round(DAC),3);

str=sprintf('%s%s%s%s','<0',ch,'r0',DAC_hex);%%%
chk=mod(sum(double(str)),256);
str=sprintf('%s%02X\r',str,chk);
out=query(s,str,'%s','%s');