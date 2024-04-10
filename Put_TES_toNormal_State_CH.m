function out=Put_TES_toNormal_State_CH(mag,Imax,nch)
%%%%Funci�n para poner el TES en estado Normal aumentando corriente con la
%%%%LNCS. La Imax es simplemente el signo para ponerlo con corrientes
%%%%positivas o negativas.
%%% Mar24. Habiamos sustituido la LNCS por la K220 y ahora la volvemos a
%%% usar pero para alimentar la bobina. Imas si se usa como valor maximo de
%%% corriente en la source normal por si no queremos pasar los 500uA.

Ilimite=25e3;%%%Corriente limite a no sobrepasar en la LNCS.
signo=sign(Imax);

% step=200;%%%Step para ir aumentando la corriente en uA.
% rfold=mag_readRf_FLL(mag);
% mag_setRf_FLL(mag,1e3);
% pause(1)
% while strcmp(Check_TES_State(mag,multi),'S')
%     iaux=mag_readLNCSImag(mag)
%     if abs(iaux)>Ilimite, 'Se ha sobrepasado la I limite',out=0;return;end
%     mag_setLNCSImag(mag,iaux+signo*step);
%     mag_readLNCSImag(mag)
% end
% 
% mag_setRf_FLL(mag,rfold);

useLNCS=1;
usek220=0;
if (useLNCS)%%%From Mar24 LNCS connected to the coil
    mag_ConnectLNCS(mag);
    mag_setLNCSImag(mag,signo*Ilimite);
    %mag_setLNCSImag(mag,signo*0.5e3);
    %%%Si queremos usar la fte en Ch1 hay que quitar la LNCS.
    %mag_setImag_CH(mag,signo*500,nch);
    mag_setImag_CH(mag,Imax,nch);
    mag_setLNCSImag(mag,0);
    mag_DisconnectLNCS(mag);
else
    %mag_setImag_CH(mag,signo*500,nch);
    mag_setImag_CH(mag,Imax,nch);
end

if usek220
    %%%%K220
    i_N=10e-3;%%%Corriente m�xima en la bobina para poner TES en estado N.
    k220=k220_init(0);
    Ibob=k220_readI(k220);
    k220_setVlimit(k220,5);
    try
        k220_Start(k220);
    catch
        k220_Start(k220);
    end
    
    try
        k220_setI(k220,i_N);
    catch
        k220_setI(k220,i_N);
    end
    pause(0.5);
    mag_setImag_CH(mag,Imax,nch);
    try
        k220_setI(k220,Ibob);
    catch
        try 
            k220_Stop(k220);
            k220_Start(k220);
        catch
            k220_Stop(k220);
            k220_Start(k220);
        end
        k220_setI(k220,Ibob);    
    end
    %fclose(k220);delete(k220)
end
%%% Comprobamos de verdad el estado del TES.
[state,slope]=Check_TES_State_CH(mag,nch,1);%%%ojo a la polaridad soft.
%slope
if strcmp(state,'N')
    out=1;%Ojo, esto devuelve siempre '1'.
else
    out=0;
end