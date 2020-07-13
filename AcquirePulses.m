function AcquirePulses(options)
%%%%Funcion de prueba para adquirir pulsos estando ya en un O.P. y guardar
%%%%en FITS. Funciona correctmente pero hay que tener bien configurado
%%%%antes la pxi, porque si no da error el writeCol.
import matlab.io.*

Npulsos=options.Npulsos;
RL=options.RL;
SR=options.SR;
multi=options.multi;
mag=options.mag;
pxi=options.pxi;
lks=options.lks;
name=options.filename;

Ibias=round(mag_readImag_CH(mag,2));
pulsetype=strcat(num2str(RL/3),'E');
ttype = {'Col1' 'Col2' 'Col3' 'Col4'};
tform = {pulsetype '1E' '1E' '1E'};

if exist(name,'file')==2
    fptr = fits.openFile(name,'readwrite');
else
    fptr=fits.createFile(name);
end
fits.createTbl(fptr,'binary',0,ttype,tform,{},'pulsos')%Tabla para los pulsos
fits.writeComment(fptr,options.comment);
t0=now;
i=0;
j=0;
dc=multi_read(multi);
while i<Npulsos && j<100
    Vout=multi_read(multi);
    %pause(1)
    if abs(Vout)>10 || abs(Vout)>1.2*abs(dc) || abs(Vout)<0.8*abs(dc)  %%%%Intentamos ver si ha saltado el squid.
'hola, reseteo squid'
        pxi_AbortAcquisition(pxi);
        Put_TES_toNormal_State_CH(mag,500,2);
        mag_setImag_CH(mag,Ibias,2);
        mag_LoopResetCH(mag,2);
        mag_LoopResetCH(mag,2);
        mag_LoopResetCH(mag,2);
        j=j+1;
    end
    try
    
    pulso=pxi_AcquirePulse(pxi,'prueba',options);
    %data=pulso(:,2);
    time=now-t0;
    lks_temp=LKS_readKelvinFromInput(lks,'A');
    Rsensor=LKS_readSensorFromInput(lks,'A');
    disp(['Pulse Number: ' num2str(i)])
    fits.writeCol(fptr,1,i+1,pulso(1:3:end,2)');
    fits.writeCol(fptr,2,i+1,time);
    fits.writeCol(fptr,3,i+1,lks_temp);
    fits.writeCol(fptr,4,i+1,Rsensor);
    i=i+1;
    catch
        pxi_AbortAcquisition(pxi);
        Put_TES_toNormal_State_CH(mag,500,2);
        mag_setImag_CH(mag,Ibias,2);
        mag_LoopResetCH(mag,2);
        mag_LoopResetCH(mag,2);
        mag_LoopResetCH(mag,2);
        j=j+1;
    end
end
fits.closeFile(fptr)
