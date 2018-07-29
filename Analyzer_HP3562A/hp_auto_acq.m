function hp_auto_acq(IbValues)
%%%Funcion para automatizar la toma de funciones de transferencia a una T
%%%dada. Hay que pasarle los valores de Ib en un array y guarda las
%%%funciones medidas en ficheros separados. Hay que implementar la función
%%%de comunicación con la caja magnicon.

%%%Comentar cuando se quiera ejecutar sobre directorio con ficheros
%%%existentes.
%if checkDirb4Acq() error('ponte en el directorio correcto');end

%instrreset();
dsa=hp_init(0);%inicializa el HP.

%hp_ss_config(dsa);%configura el HP para medir Función de
%Transferencia.Pero aqui sobra.

mag=mag_init();
%multi=multi_init();
fprintf(dsa,'SNGC');%%%Calibramos el HP.
pause(25);

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
    if(1)
        %datos=hp_measure_TF(dsa); %%% Versión que usa 20mV de excitación por defecto
    datos=hp_measure_TF(dsa,IbValues(i)*1e-6*0.1);%%%Hay que pasar el porcentaje respecto a la corriente de bias en A.
    file=strcat('TF_',Itxt,'uA','.txt');
    save(file,'datos','-ascii');%salva los datos a fichero.
    end
    
    %mide ruido
    if(1)
    datos=hp_measure_noise(dsa);
    file=strcat('HP_noise_',Itxt,'uA','.txt');
    save(file,'datos','-ascii');%salva los datos a fichero.
    end
end

%mag_setLNCSImag(mag,0);%%%Ponemos la corriente a cero.
mag_setImag_CH(mag,0,sourceCH);%%%Ponemos la corriente a cero.

fclose(dsa);delete(dsa);%cierra la comunicación con el HP y borra el obj.
fclose(mag);delete(mag);
%fclose(multi);delete(multi);

%instrreset();
