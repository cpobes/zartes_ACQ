function AcquirePulses(options)
%%%%Funcion de prueba para adquirir pulsos estando ya en un O.P. y guardar
%%%%en FITS. Funciona correctamente pero hay que tener bien configurado
%%%%antes la pxi, porque si no da error el writeCol.

%%Hay que pasar la configuración en options. Recordar incluir:
%%% Npulsos, RL, SR, filename,comment, longrun y boolplot

%%% Version Feb2024. Eliminamos check manual de Vout y fijamos el
%%% autoreset.

%%%Nota Sept2024: falta implementar uso o no de FanInOut y programar 
%%%el PRE. De momento se hace manual.

%%%Nota 30Nov2024. Cambio version para pasar IV y Rp. Ibias, I0 y V0 se
%%%calculan internamente. Se adquieren Nbaselines antes de los pulsos.

%%%10-Junio-2026. Actualizamos para adaptar a formato SIRENA.
%%%20-Nov-2026. Arreglos: caso 'TC' en la Tmc inicial y en DATE-HDU, polaridad en
%%%el paso a normal y en la recuperacion, timer del pulser (arranque unico,
%%%parada en errores, canal = SourceCH; options.Pulser/PulserCH/PulserPeriod),
%%%TIME en double, MJDREF en UTC, FileSize con baselines, SR/RL con subsampling.
%%%Equivalente Python: Zartes_New_Software/tools/acquire_pulses.py.
%%%

import matlab.io.*
uri='http://192.168.2.100:5001/channel/measurement/latest';

try%%%try catch global para poder cerrar el diary
%%%Setting Log
if strcmp(get(0,'Diary'),'on') diary off;end
DiaryFile=strcat('DiaryFile_',num2str(round(now*86400)),'_',options.filename);
x=strsplit(options.filename,'.');
DiaryFile=strrep(DiaryFile,x{end},'log');%%%ojo si el fichero no termina exactamente con .fits.
DiaryDir='DiaryFiles';
if ~exist(DiaryDir)
    mkdir(DiaryDir)
end
diary(strcat(DiaryDir,'\',DiaryFile));%%%Diary ON

Npulsos=options.Npulsos;
RL=options.RL;
if isfield(options,'Nbaselines'), NbFS=options.Nbaselines; else, NbFS=0; end
FileSize=(Npulsos+NbFS)*RL*4;%%%Nov2026: contaba solo los pulsos.
if FileSize > 1e9
    diary off;
    error('Cuidado, tamaño de fichero demasiado grande.');
end
SR=options.SR;
multi=multi_init(0);
mag=mag_init();
%%%%
flag=0;%%%flag para poner el 'otro' ch en modo AMP o no.
%%%%
try
    pxi=PXI_init();%Feb24 mejoro PXI_init(). Ya no seria necesario el try.
catch
    diary off;
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
if isfield(options,'Boptimo')
    Boptimo=options.Boptimo;
    SetBoptimo(Boptimo);%realmente es la corriente en la bobina para cancelar campo.
end
if isfield(options,'Ibias')
    Ibias=options.Ibias;%%%Ojo a si se define como A o como uA!!!!
else
    Ibias=round(mag_readImag_CH(mag,SourceCH));%%%Ojo si no se pasa Ibias y no se ha polarizado antes.
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

if isfield(options,'Tcontroller')
    Tcontroller=options.Tcontroller;
else
    Tcontroller='BF';%'BF';'LKS'
end
switch Tcontroller
    case 'BF'
        Tmc=BFreadMCTemp();
        %Tmc=0.05;%!!!
        %warning('Ojo, Tmc fijada a mano a 50mK.');
    case 'LKS'
        lks=LKS_init;
        Tmc=LKS_readKelvinFromInput(lks,'A');%%%Nov2026: antes entrada 0 (y 'A' en cada pulso).
    case 'TC'
        Tmc=TCreadTemp();%%%Nov2026: faltaba este caso (Tmc sin definir con 'TC').
    otherwise
        error('Tcontroller desconocido: %s (BF, LKS o TC)',Tcontroller);
end

pulsetype=strcat(num2str(RL/subsampling),'E');
ttype = {'ADC' 'TIME' 'Temperature' 'Resistence' 'DateTime' 'PIXID' 'PH_ID' 'BSLN'};% 'tholder'};
tform = {pulsetype '1D' '1D' '1D' '27A' '1J' '1J' '1D'};% '1D'};%%%Nov2026: TIME en double (en '1E' se perdian ms a partir de pocas horas).

if exist(name,'file')==2
    fptr = fits.openFile(name,'readwrite');
else
    fptr=fits.createFile(name);
end

%fits.writeDate(fptr); aqui da error
fits.createTbl(fptr,'binary',0,ttype,tform,{},'TESRECORDS')%Tabla para los pulsos
fits.writeKey(fptr,'SR',SR/subsampling,'sampling rate');%%%Nov2026: con subsampling, SR y RL del registro guardado.
fits.writeKey(fptr,'RL',RL/subsampling,'record length');
%fits.writeKey(fptr,'Ibias',Ibias,'Punto de operación en uA');
fits.writeKey(fptr,'Rf',Rf,'Resistencia de Feedback en Ohm');
fits.writeKey(fptr,'Tmc',Tmc,'Temperatura de la M/C');

%%%SIRENA keys%%%%%%%%%%%%%%%%%%
fits.writeKey(fptr,'TSTART',0,'start time');
fits.writeKey(fptr,'TSTOP',0,'stop time');
fits.writeKey(fptr,'TELESCOP','virtual');
fits.writeKey(fptr,'INSTRUME','virtual');
fits.writeKey(fptr,'FILTER','none');
fits.writeKey(fptr,'ANCRFILE','none');
fits.writeKey(fptr,'RESPFILE','none');
mjd=juliandate(datetime('now','TimeZone','UTC'))-2400000.5;%%%Nov2026: UTC (antes hora local).
fits.writeKey(fptr,'MJDREF',mjd,'reference MJD');
fits.writeKey(fptr,'TIMEZERO',0);
fits.writeKey(fptr,'DELTAT',subsampling/SR,'Sample time (s); inverse of sampling rate');
fits.writeKey(fptr,'RECLEN',RL/subsampling,'Record length (samples)');
%%%Nov2026: DATE-HDU del controlador elegido (antes siempre webread del BF: fallaba sin BF).
switch Tcontroller
    case 'BF'
        x=webread(uri);
    case 'TC'
        [~,x]=TCreadTemp();
    otherwise
        x.datetime=char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z'''));
end
fits.writeKey(fptr,'DATE-HDU',x.datetime);%datestr(datetime)
fits.writeKey(fptr,'INMAFILE',options.filename,'INMA data filename');
fits.writeKey(fptr,'BASESTP',0,'Constant value added to baseline.');
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%automatizamos Ibias, I0 y V0.
if isfield(options,'IV') && isfield(options,'Rp')
    IV=options.IV;
    Rp=options.Rp;
    Ibias=BuildIbiasFromRp(IV,Rp);
    fits.writeKey(fptr,'Ibias',Ibias,'Punto de operación en uA');
    fits.writeKey(fptr,'Rp',Rp,'Punto de operacion R0/Rn');
    polarity=sign(Ibias);%%%Nov2026: la polaridad es la de la Ibias calculada.
    Put_TES_toNormal_State_CH(mag,polarity*500,SourceCH);%%%Nov2026: antes +500 siempre.
    mag_setImag_CH(mag,Ibias,SourceCH);
    mag_LoopResetCH(mag,SourceCH,flag);
    Ibias=mag_readImag_CH(mag,SourceCH);
    I0=interp1(IV.ibias,IV.ites,Ibias*1e-6);
    fits.writeKey(fptr,'I0',I0,'Corriente en el TES en el punto de operacion.');
    V0=interp1(IV.ibias,IV.vtes,Ibias*1e-6);
    fits.writeKey(fptr,'V0',V0,'Voltaje en el TES en el punto de operacion.');
else
    diary off;
    fits.closeFile(fptr)
    error('You are using a new version. Use IV and Rp as fields.');
end
% if isfield(options,'I0')
%     fits.writeKey(fptr,'I0',options.I0,'Corriente en el TES en el punto de operacion.');
% end
% if isfield(options,'V0')
%     fits.writeKey(fptr,'V0',options.V0,'Voltaje en el TES en el punto de operacion.');
% end

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
%El autoreset parece afectar bastante a la estabilidad de
%Tbath, pero sin él, el DC se va facilmente de 1V y no mide bien la PXI.

pulseoptions.SR=options.SR;
pulseoptions.RL=options.RL;
pulseoptions.options.longrun=options.longrun;
pulseoptions.options.boolplot=options.boolplot;
if isfield(options,'TriggerType')
    pulseoptions.TriggerType=options.TriggerType;
end
pxi_Pulses_Configure(pxi,pulseoptions);%si hacemos longrun necesitamos configurar al menos una vez al principio.

%if(1)%%%Configurar. Esto es para poner o no el TES en el OP al empezar. Mejor no hacerlo si ya esta polarizado.
if abs(Ibias-mag_readImag_CH(mag,SourceCH))>1
    Put_TES_toNormal_State_CH(mag,sign(Ibias)*500,SourceCH);
    mag_setImag_CH(mag,Ibias,SourceCH);
    mag_LoopResetCH(mag,SourceCH,flag);
end

%CalAmpArray=[25.022 49.98   75.0069   100.029];%valores D11
%CalAmpArray=[99.73 100.2087];
if isfield(options,'Nbaselines')
    Nbaselines=options.Nbaselines;
else
    Nbaselines=0;
end
pulseoptions.TriggerType='immediate';
pxi_Pulses_Configure(pxi,pulseoptions);
tini0=0.1;%!!!pretrigger 10%.Ojo si cambia esto!

% %%%pulser
% pulsetimer=timer;
% pulsetimer.ExecutionMode='fixedrate';
% pulsetimer.BusyMode='queue';
% pulsetimer.Period=30;
% pulsetimer.TimerFcn = @(src, event) mag_setCalPulseON_CH(mag, 1);disp(char(datetime('now', 'Format', 'HH:mm:ss')));
% %start(pulsetimer)
% %%%%%%

%%%%%%%%%%%%
%%%%%%%%%%%%
st.magni    = mag;
%%%Nov2026: canal y periodo del pulso de calibracion configurables (antes canal 1 fijo en pulserTick)
%%%y opcion para no usarlo.
if isfield(options,'PulserCH'), st.ch=options.PulserCH; else, st.ch=SourceCH; end
if isfield(options,'PulserPeriod'), periodo=options.PulserPeriod; else, periodo=60; end
if isfield(options,'Pulser'), usePulser=options.Pulser; else, usePulser=true; end
st.periodo  = periodo;
st.modo     = 'rejilla';
st.t0       = tic;        % referencia temporal
st.proximo  = periodo;    % instante objetivo del siguiente pulso (s desde t0)
st.tDisparo = [];         % registro de instantes reales de disparo
st.retraso  = [];         % retraso de cada pulso respecto a su objetivo
tick = 1;
edgeConfigured=false;
t = timer('ExecutionMode', 'fixedRate', ...
          'Period',        tick, ...
          'BusyMode',      'drop', ...   % si se pierde un tick no importa
          'UserData',      st, ...
          'TimerFcn',      @pulserTick, ...
          'Name',          'pulser');
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%

while i<Npulsos+Nbaselines && j<1000 && ~exist('stop.txt','file')
%mag_setCalPulseAMP_CH(mag,0,CalAmpArray(mod(i,numel(CalAmpArray))+1),2);
    if i==0
        pause(0)%40sec is a safe wait.(30sec aun se ve la cola de la estabilizacion).
        disp('Adquiriendo baselines...')
        pulseoptions.Ncapturas=Nbaselines;
        baselines=AcquireBatchIntoArray(pulseoptions);
        if ~isempty(baselines)
            fits.writeCol(fptr,1,i+1,baselines);
        end
        disp(['Adquiridas' num2str(Nbaselines) ' baselines.'])
        i=Nbaselines;
    end
    if i==Nbaselines && ~edgeConfigured
        pulseoptions.TriggerType='edge';%%%'edge'
        pxi_Pulses_Configure(pxi,pulseoptions);
        edgeConfigured=true;%%%Nov2026: solo una vez (antes se repetia tras cada error en el primer pulso).
        %%%%
        %start(pulsetimer)%%%
        if usePulser && strcmp(t.Running,'off')
            start(t);
            disp('pulser started')
        end
    end
    try         
        pulso=pxi_AcquirePulse(pxi,'prueba',pulseoptions);
        %data=pulso(:,2);
        dc=mean(pulso(1:tini0*RL/2,2));
        time=now-t0;
        switch Tcontroller
            case 'BF'
                x=webread(uri);%lectura BF ya arreglado.
                %x.temperature=0.05;
                %x.resistance=0;
                %x.datetime='nan';
            case 'LKS'
                x.temperature=LKS_readKelvinFromInput(lks,'A');
                x.resistance=LKS_readSensorFromInput(lks,'A');
                %x.datetime=datetime;
                x.datetime = char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z'''));
            case 'TC'
                [~, x] = TCreadTemp();   % x.temperature, x.resistance, x.datetime (27 caracteres)    
        end
        fits.writeCol(fptr,1,i+1,pulso(1:subsampling:end,2)');
        fits.writeCol(fptr,2,i+1,time*86400);%10-june-2026. cambiamos a time in sec.
        fits.writeCol(fptr,3,i+1,x.temperature);
        fits.writeCol(fptr,4,i+1,x.resistance);
        fits.writeCol(fptr,5,i+1,x.datetime);%ojo al formato de datetime. Usa BF datetime 27caracteres.
        fits.writeCol(fptr,6,i+1,SourceCH);%PIXID
        fits.writeCol(fptr,7,i+1,i+1);%PH_ID
        fits.writeCol(fptr,8,i+1,dc);%BSLN
        %htemp=BFreadChannelTemp(7);
        %fits.writeCol(fptr,9,i+1,htemp);
        %fits.writeCol(fptr,3,i+1,lks_temp);
        %fits.writeCol(fptr,4,i+1,Rsensor);
        %if range(pulso(:,2))>0.05 continue;end%%%%Si se adquieren lineas de base
        disp(['Pulse Number: ' num2str(i+1)])
        i=i+1;
    catch Error
        pxi_AbortAcquisition(pxi);
        'hola, pxi_ACQ error'
        fprintf(2,'%s\n',Error.message);
        %Put_TES_toNormal_State_CH(mag,500,SourceCH,options.k220);
        Put_TES_toNormal_State_CH(mag,sign(Ibias)*500,SourceCH);%%%Nov2026: con la polaridad de Ibias.
        mag_setImag_CH(mag,Ibias,SourceCH);
        mag_LoopResetCH(mag,SourceCH,flag);
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
        [st,sl]=Check_TES_State_CH(mag,SourceCH,1);%%%(el 3er arg es la polaridad de la lectura, no la de Ibias)
        if strcmp(st,'S')
            Ibias=Ibias+sign(Ibias)*0.06;%%%Nov2026: antes +0.06 (con Ibias<0 la acercaba a 0).
            disp(['Ibias cambiado a: ' num2str(Ibias)])
            mag_setImag_CH(mag,Ibias,SourceCH);
            fprintf(2,'%s\n',strcat('Ibias set to: ',num2str(Ibias)));
        end
        j=j+1
    end
end
%mag_setAutoResetOFF_CH(mag,SourceCH); %no cerramos los instrumentos pero desactivamos el autoreset.
%mejor no desactivarlo pq si salta el Vout, se calienta todo.
%%%
%stop(pulsetimer),delete(pulsetimer)
stop(t),delete(t)
%%%
fits.closeFile(fptr)
disconnect(pxi),delete(pxi)
%fclose(lks)
diary off;
catch Error
    diary off;
    %fclose(lks)
    %%%Nov2026: parar el pulser si se ha creado (antes seguia disparando tras un error).
    if exist('t','var') && isa(t,'timer') && isvalid(t), stop(t); delete(t); end
    if ~isempty(who('fptr')) fits.closeFile(fptr);end
    error(Error.message)
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pulserTick(t, ~)
st    = t.UserData;
ahora = toc(st.t0);

if ahora < st.proximo
    return                          % aún no toca
end

try
    mag_setCalPulseON_CH(st.magni, st.ch);
catch err
    warning('pulser:error', 'Fallo al enviar pulso: %s', err.message);
    return                          % se reintenta en el siguiente tick
end

st.tDisparo(end+1) = ahora;
st.retraso(end+1)  = ahora - st.proximo;

switch st.modo
    case 'rejilla'
        % siguiente punto de la rejilla; si nos hemos saltado alguno, no se
        % lanzan pulsos seguidos para "recuperar"
        nSaltos    = floor((ahora - st.proximo) / st.periodo);
        st.proximo = st.proximo + (nSaltos + 1) * st.periodo;
    case 'desdeUltimo'
        st.proximo = ahora + st.periodo;
end

t.UserData = st;
end