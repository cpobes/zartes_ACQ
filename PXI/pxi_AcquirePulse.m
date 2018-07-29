function data=pxi_AcquirePulse(pxi,varargin)
%%%Función para adquirir y salvar en fichero un pulso o baseline con la
%%%PXI. Asume que la tarjeta está ya correctamente configurada. Se pasa
%%%como argumento el handle al instrumento y un string para identificar el
%%%nombre del fichero.

pxi_Pulses_Configure(pxi);

Options.TimeOut=5;
Options.channelList='1';

%stdpulso=0;
%while stdpulso<0.01
[data,WfmI]=pxi_GetWaveForm(pxi,Options);
%stdpulso=std(data(1:2500,2));%%%%
%end

if(1) %%%plot?
    [psd,freq]=PSD(data);
    subplot(2,1,1)
    plot(data(:,1),data(:,2));
    grid on
    subplot(2,1,2)
    %loglog(freq,psd,'.-')
    semilogx(freq,10*log10(psd),'.-')
    grid on
end

if nargin==2
    comment=varargin{1};
    file=strcat('PXI_TimeSample_',comment,'.txt');
    save(file,'data','-ascii');%salva los datos a fichero.
end