function pxi_AcquirePulse(pxi,comment)
%%%Función para adquirir y salvar en fichero un pulso o baseline con la
%%%PXI. Asume que la tarjeta está ya correctamente configurada. Se pasa
%%%como argumento el handle al instrumento y un string para identificar el
%%%nombre del fichero.

Options.TimeOut=5;
Options.channelList='0';

[data,WfmI]=pxi_GetWaveForm(pxi,Options);

[psd,freq]=PSD(data);

if(1) %%%plot?
    subplot(2,1,1)
    plot(data(:,1),data(:,2));
    grid on
    subplot(2,1,2)
    %loglog(freq,psd,'.-')
    semilogx(freq,10*log10(psd),'.-')
    grid on
end

file=strcat('PXI_TimeSample_',comment,'.txt');
save(file,'data','-ascii');%salva los datos a fichero.