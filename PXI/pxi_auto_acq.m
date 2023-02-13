function pxi_auto_acq(IbValues,varargin)
%%%Versión de la hp_auto_acq para la PXI

%%%Comentar cuando se quiera ejecutar sobre directorio con ficheros
%%%existentes.
%if checkDirb4Acq() error('ponte en el directorio correcto');end

mag=mag_init();
multi=multi_init(0);
pxi=PXI_init();

if nargin==2 %%%%%%%OJO!con k220 nargin=3.
    PXIopt=varargin{1};
else
    PXIopt.TF=1;
    PXIopt.Noise=1;
    PXIopt.Pulses=0;
    PXIopt.sourceCH=2;
end
%%%%%%%%%%%%%%try to put TES in N state.%%%%%%%%%%%%%%%
sourceCH=PXIopt.sourceCH;
Put_TES_toNormal_State_CH(mag,IbValues(1),sourceCH);%%%%

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

for i=1:length(IbValues)
    %check if stop.txt exists at every OP
    if IbValues(1) > 0
        if  exist('../stop.txt','file') 'run stopped';return;end
    elseif IbValues(1) < 0
        if  exist('../../stop.txt','file') 'run stopped';return;end
    end
    
    try
    %resetea lazo de realimentacion del squid.
    %mag_LoopResetCH(mag,sourceCH);
    %mag_setAMP_CH(mag,mod((-1)^sourceCH,3));
    
    strcat('Ibias:',num2str(IbValues(i)))
    %Set Magnicon Ib value here
    mag_setImag_CH(mag,IbValues(i),sourceCH);
    %mag_setLNCSImag(mag,IbValues(i));
    %ix=mag_readLNCSImag(mag);
    ix=mag_readImag_CH(mag,sourceCH);
    %Itxt=num2str(IbValues(i));
    Itxt=num2str(ix);
    
    %mide TF    
    if(PXIopt.TF)
        mag_LoopResetCH(mag,sourceCH);
        mag_setAMP_CH(mag,mod((-1)^sourceCH,3));
        
        porcentaje=0.05;
        excitacion=round(abs(IbValues(i)*(1e1)*porcentaje));%%%amplitud en mV para la fuente.
        if excitacion==0 %%%cuando Ibias=0, exc=0 y al usar White Noise
            %%%%en HP source se pone cero. Por algun motivo (hay bucles en
            %%%%skw) esas capturas tardan muchisimo y alargan la medida de
            %%%%2min a 12min cuando en realidad esa TF ni siquiera es
            %%%%necesaria.
            excitacion=50;
        end
        TF=pxi_AcquireTF(pxi,excitacion);
        %%%datos=pxi_measure_TF(dsa,IbValues(i)*1e-6*0.02);%%%Hay que pasar el porcentaje respecto a la corriente de bias en A.
        file=strcat('PXI_TF_',Itxt,'uA','.txt');
        save(file,'TF','-ascii');%salva los datos a fichero.
    end
    
    pause(1)
    %mide ruido
    n_avg=5;%%%<-Averages para el ruido.
    nopt.SR=2e5;
    nopt.RL=2e5;
    nopt.subsampling.bool=0;
    nopt.subsampling.NpointsDec=100;
    if(PXIopt.Noise)
        if isfield(PXIopt,'nSR')
            nopt.SR=PXIopt.nSR;
        end
        if isfield(PXIopt,'nRL')
            nopt.RL=PXIopt.nRL;
        end
        if isfield(PXIopt,'subsampling')
            nopt.subsampling.bool=PXI.subsampling.bool;
            nopt.subsampling.NpointsDec=PXI.subsampling.NpointsDec;
        end
        mag_LoopResetCH(mag,sourceCH);
        mag_setAMP_CH(mag,mod((-1)^sourceCH,3));
        %pxi_Noise_Configure(pxi); no necesario. esta dentro de AcqPSD.
        pause(1)
        aux=pxi_AcquirePSD(pxi,nopt);
        datos=aux;
        for jj=1:n_avg-1%%%Ya hemos adquirido una.
            aux=pxi_AcquirePSD(pxi,nopt);
            datos(:,2)=datos(:,2)+aux(:,2);
        end
        datos(:,2)=datos(:,2)/n_avg;
        file=strcat('PXI_noise_',Itxt,'uA','.txt');
        save(file,'datos','-ascii');%salva los datos a fichero.
    end
    
    pause(1)
    %mide pulsos
    if (PXIopt.Pulses)
        if(0)
        %%%%Pulsos de corriente
        mag_Configure_CalPulse(mag);%%%configuramos la fuente(AMP por defecto 20uA).Ojo, el canal no se pasa como parametro.
        %%%Resetea lazo para anular la componente DC del CH1. OJO: lo
        %%%robusto es sacar señal de trigger y meterla por Trigger EXT.
        mag_LoopResetCH(mag,sourceCH);
        mag_setAMP_CH(mag,mod((-1)^sourceCH,3));
        %vdc=mean(multi_read(multi))
        %opt.Level=vdc-0.04;%%%Amplitude dependent trigger above DC level.
        %pxi_Pulses_Configure(pxi,opt);%%%configuramos la pxi para adquirir pulsos.
        %pause(1)
        
        vdc=-mode(multi_read(multi));%%%OJO! el valor en el HP es opuesto en signo al de la PXI!!!
        mag_setCalPulseON_CH(mag,sourceCH);%%activamos la fuente
        %%%'NISCOPE_VAL_VOLTAGE_BASE'=26
        %invoke(pxi.Measurement,'addwaveformprocessing','1',26);
        %vdc=pxi_getMeasurement(pxi,'1',26)
        opt.Level=vdc-0.005;%%%Amplitude dependent trigger above DC level.
        end

    %%%%Pulsos de Fe55
    %%%%%
        opt.RL=1e4;%%%%Esto deberiamos pasarlo como config.
        opt.SR=2e5;
        pxi_Pulses_Configure(pxi,opt);%%%configuramos la pxi para adquirir pulsos. Con modulo trigger no pasamos Level.
        pause(1)
        mag_LoopResetCH(mag,sourceCH);
        mag_setAMP_CH(mag,mod((-1)^sourceCH,3));
        try 
            datos=pxi_AcquirePulse(pxi);
        catch Error
            datos=[];
            pxi_AbortAcquisition(pxi);
            fprintf(2,'Error en Pulsos ACQ:\n%s\n',Error.message);
        end
        %mag_setCalPulseOFF_CH(mag,2);%%desactivamos la fuente.
        
        mkdir Pulsos
        cd Pulsos
        file=strcat('PXI_Pulso_',Itxt,'uA','.txt');
        save(file,'datos','-ascii');%salva los datos a fichero.
        cd ..
        %pause(1)
    end
    catch Error
        strcat('error pxi Ib: ',num2str(IbValues(i)))
        fprintf(2,'%s\n',Error.message);
    end
end

%mag_setLNCSImag(mag,0);%%%Ponemos la corriente a cero.
mag_setImag_CH(mag,0,sourceCH);%%%Ponemos la corriente a cero.

%fclose(dsa);delete(dsa);%cierra la comunicación con el HP y borra el obj.
fclose(mag);delete(mag);
disconnect(pxi);delete(pxi);
fclose(multi);delete(multi);
instrreset;