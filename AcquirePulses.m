function AcquirePulses(options)
%%%%Funcion de prueba para adquirir pulsos estando ya en un O.P. y guardar
%%%%en FITS. Funciona correctmente pero hay que tener bien configurado
%%%%antes la pxi, porque si no da error el writeCol.

%%Hay que pasar la configuración en options. Recordar incluir:
%%% Npulsos, RL, SR, filename,comment, longrun y boolplot

%%% Version Feb2024. Eliminamos check manual de Vout y fijamos el
%%% autoreset.
import matlab.io.*
uri='http://192.168.2.121:5001/channel/measurement/latest';

try%%%try catch global para poder cerrar el diary
%%%Setting Log
if strcmp(get(0,'Diary'),'on') diary off;end
DiaryFile=strcat('DiaryFile_',num2str(round(now*86400)),'_',options.filename);
x=strsplit(options.filename,'.');
DiaryFile=strrep(DiaryFile,x{end},'log');%%%ojo si el fichero no termina exactamente con .fits.
diary(DiaryFile);%%%Diary ON

Npulsos=options.Npulsos;
RL=options.RL;
SR=options.SR;
multi=multi_init(0);
mag=mag_init();
try
    pxi=PXI_init();%Feb24 mejoro PXI_init(). Ya no seria necesario el try.
catch
    error('Error inicializando la PXI.')
end
%lks=options.lks
%k220=options.k220;
name=options.filename;
pxi_Pulses_Configure(pxi,options);

if isfield(options,'subsampling')
    subsampling=options.subsampling;%step
else
    subsampling=1;%step
end
if isfield(options,'SourceCH')
    SourceCH=options.SourceCH;
else
    SourceCH=2;
end
if isfield(options,'Ibias')
    Ibias=options.Ibias;%%%Ojo a si se define como A o como uA!!!!
else
    Ibias=round(mag_readImag_CH(mag,SourceCH))*1e-6;
end
if isfield(options,'polarity')
    polarity=options.polarity;
else
    %polarity=1;
    polarity=sign(Ibias);%%%%Solo se usa para Poner el TES normal.
end
if isfield(options,'Rf')
    Rf=options.Rf;
    mag_setRf_FLL_CH(mag,Rf,SourceCH);
else
    Rf=mag_readRf_FLL_CH(mag,SourceCH);
end

Tmc=BFreadMCTemp();

pulsetype=strcat(num2str(RL/subsampling),'E');
ttype = {'Pulso' 'Time' 'Temperature' 'Resistence' 'DateTime'};
tform = {pulsetype '1E' '1D' '1D' '27A'};

if exist(name,'file')==2
    fptr = fits.openFile(name,'readwrite');
else
    fptr=fits.createFile(name);
end
%fits.writeDate(fptr); aqui da error
fits.createTbl(fptr,'binary',0,ttype,tform,{},'pulsos')%Tabla para los pulsos
fits.writeKey(fptr,'SR',SR,'sampling rate');
fits.writeKey(fptr,'RL',RL,'record length');
fits.writeKey(fptr,'Ibias',Ibias,'Punto de operación en A');
fits.writeKey(fptr,'Rf',Rf,'Resistencia de Feedback en Ohm');
fits.writeKey(fptr,'Tmc',Tmc,'Temperatura de la M/C');
if isfield(options,'I0')
    fits.writeKey(fptr,'I0',options.I0,'Corriente en el TES en el punto de operacion.');
end
if isfield(options,'V0')
    fits.writeKey(fptr,'V0',options.V0,'Voltaje en el TES en el punto de operacion.');
end
%otras opciones de configuracion.

fits.writeDate(fptr);
fits.writeComment(fptr,options.comment);
t0=now;
i=0;
j=0;
dc=multi_read(multi);

%%%Configuramos Autoreset.
if isfield(options,'ResetTHR')
    ResetTHR=options.ResetTHR;
else
    ResetTHR=1.05;%%%voltaje para resetear el lazo. Con esto no debería ser necesario el loopreset manual.
end
fits.writeKey(fptr,'ResetTHR',ResetTHR,'Valor del Autoreset de la electronica magnicon.');
mag_setAutoResetON_CH(mag,ResetTHR,SourceCH);

pulseoptions.SR=options.SR;
pulseoptions.RL=options.RL;
pulseoptions.options.longrun=options.longrun;
pulseoptions.options.boolplot=options.boolplot;
%pxi_Pulses_Configure(pxi,pulseoptions);%si hacemos longrun necesitamos configurar al menos una vez al principio.

if(0)%%%Configurar. Esto es para poner o no el TES en el OP al empezar. Mejor no hacerlo si ya esta polarizado.
    Put_TES_toNormal_State_CH(mag,500,SourceCH);
    mag_setImag_CH(mag,Ibias*1e6,SourceCH);
    mag_LoopResetCH(mag,SourceCH);
end

%CalAmpArray=[25.022 49.98   75.0069   100.029];%valores D11
%CalAmpArray=[99.73 100.2087];

while i<Npulsos && j<1000 && ~exist('stop.txt','file')
    %mag_setCalPulseAMP_CH(mag,0,CalAmpArray(mod(i,numel(CalAmpArray))+1),2);

    try   
        pulso=pxi_AcquirePulse(pxi,'prueba',pulseoptions);
        %data=pulso(:,2);
        time=now-t0;
        x=webread(uri);
        %lks_temp=LKS_readKelvinFromInput(lks,'A');
        %Rsensor=LKS_readSensorFromInput(lks,'A');
        fits.writeCol(fptr,1,i+1,pulso(1:subsampling:end,2)');
        fits.writeCol(fptr,2,i+1,time);
        fits.writeCol(fptr,3,i+1,x.temperature);
        fits.writeCol(fptr,4,i+1,x.resistance);
        fits.writeCol(fptr,5,i+1,x.datetime);
        %fits.writeCol(fptr,3,i+1,lks_temp);
        %fits.writeCol(fptr,4,i+1,Rsensor);
        %if range(pulso(:,2))>0.05 continue;end%%%%Si se adquieren lineas de base
        disp(['Pulse Number: ' num2str(i)])
        i=i+1;
    catch Error
        pxi_AbortAcquisition(pxi);
        'hola, pxi_ACQ error'
        fprintf(2,'%s\n',Error.message);
        %Put_TES_toNormal_State_CH(mag,500,SourceCH,options.k220);
        Put_TES_toNormal_State_CH(mag,500,SourceCH);
        mag_setImag_CH(mag,Ibias*1e6,SourceCH);
        mag_LoopResetCH(mag,SourceCH);
        Vout=multi_read(multi);
        %%monitoreo de vout
        %rango=1e3;
        rango=multi_monitor(multi); 
        icounter=1;
        while rango>10e-4
            strcat('monitoring','.')
            rango=multi_monitor(multi);           
            fprintf(1,'%s','.');
            if ~mod(icounter,10) fprintf(1,'\n');end
            icounter=icounter+1;
            if icounter>100 break;end%por si acaso.
        end
        [st,sl]=Check_TES_State_CH(mag,SourceCH,1);
        if strcmp(st,'S')
            Ibias=Ibias+0.06;
            disp(['Ibias cambiado a: ' num2str(Ibias)])
            mag_setImag_CH(mag,Ibias*1e6,SourceCH);
            fprintf(2,'%s\n',strcat('Ibias set to: ',num2str(Ibias)));
        end
        j=j+1
    end
end
%mag_setAutoResetOFF_CH(mag,SourceCH); %no cerramos los instrumentos pero desactivamos el autoreset.
%mejor no desactivarlo pq si salta el Vout, se calienta todo.
fits.closeFile(fptr)
disconnect(pxi),delete(pxi)
catch Error
    diary off;
    disp(Error.message)
end