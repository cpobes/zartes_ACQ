function hp_auto_acq(IbValues,varargin)
%%%Funcion para automatizar la toma de funciones de transferencia a una T
%%%dada. Hay que pasarle los valores de Ib en un array y guarda las
%%%funciones medidas en ficheros separados. Hay que implementar la funci�n
%%%de comunicaci�n con la caja magnicon.

%%%Comentar cuando se quiera ejecutar sobre directorio con ficheros
%%%existentes.
%if checkDirb4Acq() error('ponte en el directorio correcto');end

%instrreset();
dsa=hp_init(0);%inicializa el HP.
mag=mag_init();
multi=multi_init(0);%
%multi=multi_init();

if nargin==2
    HPopt=varargin{1};
else
    HPopt.TF=1;
    HPopt.Noise=1;
    HPopt.sourceCH=2;
end
sourceCH=HPopt.sourceCH;

%%%use fan in fan out
%%%%
if isfield(HPopt,'useFanInOut')
    useFanInOut=HPopt.useFanInOut;
else
    useFanInOut=0;%%%Abril 2024
end

if useFanInOut
    fan=fanout_init();
    switch sourceCH
        case 1
            CH='b';
        case 2
            CH='B';
    end
    fanout_set(fan,CH);
    fclose(fan);
end

%%%%%%%%%%%%%%try to put TES in N state.%%%%%%%%%%%%%%%
Put_TES_toNormal_State_CH(mag,IbValues(1),sourceCH);

%resetea lazo de realimentacion del squid.
mag_LoopResetCH(mag,sourceCH);%ojo.LoopReset resetea ambos canales.
mag_setAMP_CH(mag,mod((-1)^sourceCH,3));%mejor poner en AMP el otro.

%%%Calibramos el HP despu�s de Put y Reset.
fprintf(dsa,'SNGC');
pause(35);

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
rangoTHR=5e-3;
for i=1:length(IbValues)
    %check if stop.txt exists at every OP
    if IbValues(1) > 0
        if  exist('../stop.txt','file') 'run stopped',return;end
    elseif IbValues(1) < 0
        if  exist('../../stop.txt','file') 'run stopped',return;end
    end
    
    try

    disp(strcat('Ibias:',num2str(IbValues(i)),'uA'));
    %Set Magnicon Ib value here
    mag_setImag_CH(mag,IbValues(i),sourceCH);
    %mag_setLNCSImag(mag,IbValues(i));
    %ix=mag_readLNCSImag(mag);
    ix=mag_readImag_CH(mag,sourceCH);
    %Itxt=num2str(IbValues(i));
    Itxt=num2str(ix);
    
    %%%%%%%%%%%%%%%%mide TF
    if(HPopt.TF)
        %datos=hp_measure_TF(dsa); %%% Versi�n que usa 20mV de excitaci�n por defecto
        mag_LoopResetCH(mag,sourceCH);
        mag_setAMP_CH(mag,mod((-1)^sourceCH,3));
        %%%%Monitorizacion Vout
        rango=1e3;
        %%%Si la salida es estable, la fluctaci�n en la
        %%%salida es menor de 1mV.
        rangoindx=1;
        while rango>rangoTHR%5e-4
            rango=multi_monitor(multi);
            disp(strcat('monitoring...',num2str(rangoindx)));
            rangoindx=rangoindx+1;
            if rangoindx>25 break;end
        end
        %%%%%%%
        porcentaje=0.05;%%%%<-Porcentaje!
        Excitacion=abs(IbValues(i)*1e-6*porcentaje);
        hp_ss_config(dsa);
        if isfield(HPopt,'Excitacion')
            Excitacion=HPopt.Excitacion;
            if Excitacion>1 Excitacion=Excitacion*1e-7;end%se pasa en mV
            if Excitacion<1 && Excitacion>0.001 Excitacion=Excitacion*1e-4;end%se pasa en V.
        else
            Excitacion=20e-7;%%%Abril 2024
        end
        if Excitacion==0
            Excitacion=50*1e-7;%!
        end
        %%%
        if useFanInOut
            fan=fanout_init();
            switch sourceCH
                case 1
                    sCH='a';
                case 2
                    sCH='A';
            end
            fanout_set(fan,sCH);
            fclose(fan);
        end
        %%%
        %Excitacion=25*1e-7;%%%Debug!!!
        datos=hp_measure_TF(dsa,Excitacion);%%%Hay que pasar el porcentaje respecto a la corriente de bias en A.
        %datos=hp_measure_TF(dsa);
        file=strcat('TF_',Itxt,'uA','.txt');
        save(file,'datos','-ascii');%salva los datos a fichero.
        disp(sprintf('File %s salvado.',file));
        %disp(strcat('File ',file,' salvado.'));
    end
    
    %mide ruido
    if(HPopt.Noise)
        %resetea lazo de realimentacion del squid.
        mag_LoopResetCH(mag,sourceCH);%ojo.LoopReset resetea ambos canales.
        mag_setAMP_CH(mag,mod((-1)^sourceCH,3));%mejor poner en AMP el otro.
        
        %%%%Monitorizacion Vout
        rango=1e3;
        %%%Si la salida es estable, la fluctaci�n en la
        %%%salida es menor de 1mV.
        rangoindx=1;
        while rango>rangoTHR%5e-4
            rango=multi_monitor(multi);
            disp(strcat('monitoring...',num2str(rangoindx)));
            rangoindx=rangoindx+1;
            if rangoindx>25 break;end
        end
        %%%%%%
        hp_noise_config(dsa);
        %%%
        if useFanInOut
            fan=fanout_init();
            switch sourceCH
                case 1
                    CH='b';
                case 2
                    CH='B';
            end
            fanout_open(fan);%para apagar la salida de la source para Zs.
            pause(2.5)
            fanout_set(fan,CH);
            fclose(fan);
        end
        %%%
        hp_single_CAL(dsa);
        pause(35); %%%(el CAl tarda entre 29-32seg).
        datos=hp_measure_noise(dsa);
        file=strcat('HP_noise_',Itxt,'uA','.txt');
        save(file,'datos','-ascii');%salva los datos a fichero.
        disp(sprintf('File %s salvado.',file));
        %disp(strcat('File ',file,' salvado.'));
    end
    catch Error
        strcat('error HP Ib: ',num2str(i))
        fprintf(2,'%s\n',Error.message);
    end %%%try catch
end

%mag_setLNCSImag(mag,0);%%%Ponemos la corriente a cero.
mag_setImag_CH(mag,0,sourceCH);%%%Ponemos la corriente a cero.
mag_setAMP_CH(mag,1);
mag_setAMP_CH(mag,2);

fclose(dsa);delete(dsa);%cierra la comunicaci�n con el HP y borra el obj.
fclose(mag);delete(mag);
fclose(multi);delete(multi);