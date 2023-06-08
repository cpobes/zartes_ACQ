function data=pxi_AcquirePulse(pxi,varargin)
%%%Función para adquirir y salvar en fichero un pulso o baseline con la
%%%PXI. Asume que la tarjeta está ya correctamente configurada. Se pasa
%%%como argumento el handle al instrumento y un string para identificar el
%%%nombre del fichero.

boolplot=1;
boolsave=1;
longrun=0;
if nargin==3
    conf=varargin{2};
    if isfield(conf,'options')
        longrun=conf.options.longrun;
        boolplot=conf.options.boolplot;
        boolsave=~longrun;%%%Si es run largo, no guardamos el temp.
    end
    if ~longrun pxi_Pulses_Configure(pxi,conf);end  %%%si es longrun no reconfiguramos cada vez, pero hay que hacerlo 1 vez al principio.
else
    %pxi_Pulses_Configure(pxi);%%%!configuraba por defecto !BUG.
end
%pxi_Pulses_Configure(pxi);

Options.TimeOut=12;
Options.channelList='1';

%stdpulso=0;
%while stdpulso<0.01
[data,WfmI]=pxi_GetWaveForm(pxi,Options);
%stdpulso=std(data(1:2500,2));%%%%
%end

if(boolplot) %%%plot?
    boolremoveoffset=1;%config.
     auxhandle_pulsos=findobj('name','Pulsos');
     if isempty(auxhandle_pulsos) figure('name','Pulsos'); auxhandle_pulsos=findobj('name','Pulsos'); else figure(auxhandle_pulsos);end
    [psd,freq]=PSD(data);
    subplot(2,1,1)
    plot(data(:,1),data(:,2)-boolremoveoffset*data(1,2),'.-');
    grid on
    subplot(2,1,2)
    %loglog(freq,psd,'.-')
    semilogx(freq,10*log10(psd),'.-')
    grid on
end

if nargin>1 & boolsave
    comment=varargin{1};
    file=strcat('PXI_TimeSample_',comment,'.txt');
    save(file,'data','-ascii');%salva los datos a fichero.
end