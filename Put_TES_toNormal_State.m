function out=Put_TES_toNormal_State(mag,Imax)
%%%%Funci�n para poner el TES en estado Normal aumentando corriente con la
%%%%LNCS. La Imax es simplemente el signo para ponerlo con corrientes
%%%%positivas o negativas.

Ilimite=25000;%%%Corriente limite a no sobrepasar.

% step=200;%%%Step para ir aumentando la corriente en uA.
 signo=sign(Imax);
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

mag_ConnectLNCS(mag);
mag_setLNCSImag(mag,signo*Ilimite);
mag_setLNCSImag(mag,signo*0.5e3);
%%%Si queremos usar la fte en Ch1 hay que quitar la LNCS.
mag_setImag(mag,signo*500);
mag_setLNCSImag(mag,0);
mag_DisconnectLNCS(mag);
out=1;%Ojo, esto devuelve siempre '1'.