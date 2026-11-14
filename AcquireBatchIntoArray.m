function OutputBuffer=AcquireBatchIntoArray(options)
%%%funcion similar a AcquireBaselinesBatch pero sin usar ficehros fits,
%%%leyendo los datos a un array.
%%%Asumimos que el TES está polarizado ya.

max_RL=1e6;%cogemos en batches de 1M.
Ncapturas=options.Ncapturas;
RL=options.RL;
SR=options.SR;

%check
if mod(Ncapturas,max_RL/RL) 
    disp(['Ncapturas:' ' ' num2str(Ncapturas)]);
    disp(['Tamaño batch:' ' ' num2str(max_RL/RL)]);
    error('Ncapturas no es multiplo del tamaño del batch');
end
if mod(max_RL,RL) 
    error('RL no es multiplo de max_RL=1e6');
end

%%%Configuramos Autoreset.
if isfield(options,'ResetTHR')
    ResetTHR=options.ResetTHR;
else
    ResetTHR=1.05;%%%voltaje para resetear el lazo. Con esto no debería ser necesario el loopreset manual.
end
if isfield(options,'SourceCH')
    SourceCH=options.SourceCH;
else
    SourceCH=1;
end
% mag=mag_init();
% mag_setAutoResetON_CH(mag,ResetTHR,SourceCH);
% fclose(mag);

pulseoptions.SR=options.SR;
pulseoptions.RL=max_RL;
%pulseoptions.options.longrun=options.longrun;
%pulseoptions.options.boolplot=options.boolplot;
if isfield(options,'TriggerType')
    pulseoptions.TriggerType=options.TriggerType;
end

pxi=PXI_init();
pxi_Pulses_Configure(pxi,pulseoptions);

i=0;
index=0;
OutputBuffer=[];
Nbatches=Ncapturas*RL/max_RL;
while i<Nbatches
        pulso=pxi_AcquirePulse(pxi,'prueba',pulseoptions);
        buffer=reshape(pulso(:,2),[RL numel(pulso(:,2))/RL])';
        disp(['Capture Number: ' num2str(i+1)])
        i=i+1;
        index=i*(max_RL/RL);
        OutputBuffer=[OutputBuffer;buffer];
end
%disconnect(pxi),delete(pxi)