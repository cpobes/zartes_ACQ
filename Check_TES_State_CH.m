function state=Check_TES_State_CH(mag,multi,nch)
%%%Funcion para comprobar el estado del TES

%DeltaI=10*3.05;%%Delta de corriente en la fuente LNCS.
DeltaI=10*1.7;%Delta de corriente en la fte normal.
%mS=8/3;%%%Slope en estado superconductor/3K
%mN=0.3;%%Slope en estado normal.
Rf=mag_readRf_FLL_CH(mag,nch);
%Iaux1=mag_readLNCSImag(mag);
Iaux1=mag_readImag_CH(mag,nch);
Vaux1=multi_read(multi);
%mag_setLNCSImag(mag,Iaux1+DeltaI);
mag_setImag_CH(mag,Iaux1+DeltaI,nch);
pause(2);
%Iaux2=mag_readLNCSImag(mag);
Iaux2=mag_readImag_CH(mag,nch);
Vaux2=multi_read(multi);
Slope=(Vaux2-Vaux1)/((Iaux2-Iaux1)*1e-6)/Rf;
%mag_setLNCSImag(mag,Iaux1);%devolvemos al estado inicial.
mag_setImag_CH(mag,Iaux1,nch);%devolvemos al estado inicial.

%%%%la pendiente crítica es más o menos '1'. Para estado superconductor 
%%%%tenemos mS=8000 para Rf=3K -> ms'=2.67. y mN=900 tb para Rf=3K por lo
%%%%que mN'=0.3. Podemos usar por tanto mcritica=1 como criterio.
if Slope>1
    state='S';
elseif Slope<1
    state='N';
end
    