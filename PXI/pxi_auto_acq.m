function pxi_auto_acq(IbValues)
%%%Versión de la hp_auto_acq para la PXI

%%%Comentar cuando se quiera ejecutar sobre directorio con ficheros
%%%existentes.
%if checkDirb4Acq() error('ponte en el directorio correcto');end



%hp_ss_config(dsa);%configura el HP para medir Función de
%Transferencia.Pero aqui sobra.

mag=mag_init();
multi=multi_init();
pxi=PXI_init();

%%%%%%%%%%%%%%try to put TES in N state.%%%%%%%%%%%%%%%

sourceCH=2;
Put_TES_toNormal_State_CH(mag,IbValues(1),sourceCH);

%Check_TES_State(mag,multi)
%if strcmp(Check_TES_State(mag,multi),'S'),'SState',return;end

% if IbValues(1)>0
%     out=mag_setImag(mag,500);
%     if strcmp(out,'FAIL') instrreset;return;end
%     mag_readLNCSImag(mag)
% elseif IbValues(1)<0
%     out=mag_setImag(mag,-500);
%     if strcmp(out,'FAIL') instrreset;return;end
%     mag_readLNCSImag(mag)
% end

%instrreset;return

%fprintf(dsa,'DCOF 5V');
%fprintf(dsa,'SRON');%source ON
%fprintf(dsa,'DCOF 9.9V');
% 
% 'cambia BNC'
% pause(20);
% 'measure start'

%fprintf(dsa,'DCOF 5V');
%fprintf(dsa,'DCOF 0V');
%fprintf(dsa,'SRON');%source off (toggle)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%questdlg('TES normal?')

for i=1:length(IbValues)
    
    %resetea lazo de realimentacion del squid.
    mag_setAMP_CH(mag,sourceCH);
    mag_setFLL_CH(mag,sourceCH);

    strcat('Ibias:',num2str(IbValues(i)))
    %Set Magnicon Ib value here
    %SetIb(IbValues(i));
    mag_setImag_CH(mag,IbValues(i),sourceCH);
    %mag_setLNCSImag(mag,IbValues(i));
    %ix=mag_readLNCSImag(mag);
    ix=mag_readImag_CH(mag,sourceCH);
    %Itxt=num2str(IbValues(i));
    Itxt=num2str(ix);
    
    %mide TF
    mag_LoopResetCH(mag,sourceCH);
    if(1)
        %%%configure HP Fixed SINE y hacer barrido en frecuencia.
        porcentaje=0.05;
        excitacion=IbValues(i)*(1e1)*porcentaje;%%%amplitud en mV para la fuente.
        TF=pxi_AcquireTF(pxi,excitacion);
        %%%datos=pxi_measure_TF(dsa,IbValues(i)*1e-6*0.02);%%%Hay que pasar el porcentaje respecto a la corriente de bias en A.
        file=strcat('PXI_TF_',Itxt,'uA','.txt');
        save(file,'TF','-ascii');%salva los datos a fichero.
    end
    
    pause(1)
    %mide ruido
    mag_LoopResetCH(mag,sourceCH);
    if(1)
        pxi_Noise_Configure(pxi);
        pause(1)
        aux=pxi_AcquirePSD(pxi);
        datos=aux;
        n_avg=5;
        for jj=1:n_avg-1%%%Ya hemos adquirido una.
            aux=pxi_AcquirePSD(pxi);
            datos(:,2)=datos(:,2)+aux(:,2);
        end
        datos(:,2)=datos(:,2)/n_avg;
        file=strcat('PXI_noise_',Itxt,'uA','.txt');
        save(file,'datos','-ascii');%salva los datos a fichero.
    end
    
    pause(1)
    %mide pulsos
    if (1)
        
        %%%%Pulsos de corriente
%         mag_Configure_CalPulse(mag);%%%configuramos la fuente(AMP por defecto 20uA).Ojo, el canal no se pasa como parametro.
%         %%%Resetea lazo para anular la componente DC del CH1. OJO: lo
%         %%%robusto es sacar señal de trigger y meterla por Trigger EXT.
%         mag_LoopResetCH(mag,sourceCH);
%         %vdc=mean(multi_read(multi))
%         %opt.Level=vdc-0.04;%%%Amplitude dependent trigger above DC level.
%         %pxi_Pulses_Configure(pxi,opt);%%%configuramos la pxi para adquirir pulsos.
%         %pause(1)
%         mag_setCalPulseON_CH(mag,2);%%activamos la fuente
%         vdc=-mode(multi_read(multi));%%%OJO! el valor en el HP es opuesto en signo al de la PXI!!!
%         %%%'NISCOPE_VAL_VOLTAGE_BASE'=26
%         %invoke(pxi.Measurement,'addwaveformprocessing','1',26);
%         %vdc=pxi_getMeasurement(pxi,'1',26)
%         opt.Level=vdc-0.005;%%%Amplitude dependent trigger above DC level.
        

    %%%%Pulsos de Fe55
    %%%%%
        pxi_Pulses_Configure(pxi);%%%configuramos la pxi para adquirir pulsos. Con modulo trigger no pasamos Level.
        pause(1)
        try
            datos=pxi_AcquirePulse(pxi);
        catch
            datos=[];
            pxi_AbortAcquisition(pxi);
        end
        %mag_setCalPulseOFF_CH(mag,2);%%desactivamos la fuente
        
        mkdir Pulsos
        cd Pulsos
        file=strcat('PXI_Pulso_',Itxt,'uA','.txt');
        save(file,'datos','-ascii');%salva los datos a fichero.
        cd ..
        %pause(1)
    end
    
end

%mag_setLNCSImag(mag,0);%%%Ponemos la corriente a cero.
mag_setImag_CH(mag,0,sourceCH);%%%Ponemos la corriente a cero.

%fclose(dsa);delete(dsa);%cierra la comunicación con el HP y borra el obj.
fclose(mag);delete(mag);
disconnect(pxi);delete(pxi);
fclose(multi);delete(multi);