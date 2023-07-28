function AcquirePulses(options)
%%%%Funcion de prueba para adquirir pulsos estando ya en un O.P. y guardar
%%%%en FITS. Funciona correctmente pero hay que tener bien configurado
%%%%antes la pxi, porque si no da error el writeCol.

%%Hay que pasar la configuración en options. Recordar incluir:
%%% Npulsos, RL, SR, filename,comment, longrun y boolplot
import matlab.io.*

uri='http://192.168.2.121:5001/channel/measurement/latest';

Npulsos=options.Npulsos;
RL=options.RL;
SR=options.SR;
multi=multi_init(0);%options.multi;
mag=mag_init();%mag=options.mag;
%pxi=options.pxi;
pxi=PXI_init();
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
if isfield(options,'polarity')
    polarity=options.polarity;
else
    polarity=1;
end

Ibias=round(mag_readImag_CH(mag,SourceCH))*1e-6;
Rf=mag_readRf_FLL_CH(mag,SourceCH);

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
%otras opciones de configuracion.

fits.writeDate(fptr);
fits.writeComment(fptr,options.comment);
t0=now;
i=0;
j=0;
dc=multi_read(multi);
ResetTHR=1.0;%%%voltaje para resetear el lazo. Con esto no debería ser necesario el loopreset manual.
mag_setAutoResetON_CH(mag,ResetTHR,SourceCH);
while i<Npulsos && j<1000 && ~exist('stop.txt','file')
    Vout=multi_read(multi);
    %pause(1)
    if abs(Vout)>0.8 %%%Si offset mal reseteamos lazo 3 veces para probar
        'SIMPLE LOOP RESET'
        mag_LoopResetCH(mag,SourceCH);
        mag_LoopResetCH(mag,SourceCH);
        mag_LoopResetCH(mag,SourceCH);
        pause(1)%%%Se ven derivas en el DC tras un salto del Squid.
    end
    if abs(Vout)>0.8 %|| abs(Vout)>1.2*abs(dc) || abs(Vout)<0.8*abs(dc)  %%%%Intentamos ver si ha saltado el squid.
    'hola, FULL RESET'
        pxi_AbortAcquisition(pxi);
        
        %Put_TES_toNormal_State_CH(mag,500,SourceCH,options.k220);
        Put_TES_toNormal_State_CH(mag,polarity*500,SourceCH);
%         mag_setImag_CH(mag,500,2);
%         k220_setI(k220,10e-3);
%         pause(0.5)
%         k220_setI(k220,1.24e-3);%%%vuelta a valor optimo
        
        mag_setImag_CH(mag,Ibias,SourceCH);
        mag_LoopResetCH(mag,SourceCH);
        %%monitoreo de vout
        rango=1e3;
        strcat('monitoring','.')
        icounter=1;
        while rango>5e-4
            rango=multi_monitor(multi);           
            fprintf(1,'%s','.');
            if ~mod(icounter,10) fprintf(1,'\n');end
            icounter=icounter+1;
            if icounter>100 break;end%por si acaso.
        end
        j=j+1;
        %pause(3)%%% Si hay que resetear el TES puede notarlo un poco la Tbath.
    end
    try   
        pulseoptions.SR=options.SR;
        pulseoptions.RL=options.RL;
        pulseoptions.options.longrun=options.longrun;
        pulseoptions.options.boolplot=options.boolplot;
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
        %mag_setImag_CH(mag,Ibias,SourceCH);
        %mag_LoopResetCH(mag,SourceCH);
        %j=j+1
    end
end
mag_setAutoResetOFF_CH(mag,SourceCH);
%no cerramos los instrumentos pero desactivamos el autoreset.
fits.closeFile(fptr)
