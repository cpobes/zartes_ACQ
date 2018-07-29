function datos=pxi_AcquirePSD(pxi,varargin)
%%%Función para adquirir y salvar en fichero un espectro PSD con la
%%%PXI. Asume que la tarjeta está ya correctamente configurada. Se pasa
%%%como argumento el handle al instrumento y un string para identificar el
%%%nombre del fichero.

Options.TimeOut=5;
Options.channelList='1';

[data,WfmI]=pxi_GetWaveForm(pxi,Options);

[psd,freq]=PSD(data);

if(1)%%%subsampleo?
    if freq(1)==0, logfmin=log10(freq(2));end%%%%Ojo, pq PSD hace fmin=0 siempre.?!
    logfmax=log10(freq(end));
    Ndec=logfmax-logfmin;
    NpointsDec=200;%%%
    N=NpointsDec*Ndec;%%%numero de puntos.
    xx=logspace(logfmin,logfmax,N+1);%%%subsampleamos entre 1Hz y 100KHz.
    psd=interp1(freq,psd,xx);
    freq=xx;
end

if(1) %%%plot?
    subplot(2,1,1)
    plot(data(:,1),data(:,2));
    grid on
    subplot(2,1,2)
    %loglog(freq,psd,'.-')
    semilogx(freq,10*log10(psd),'.-')
    grid on
end

datos(:,1)=freq;
datos(:,2)=sqrt(psd);

if nargin==2
    comment=varargin{1};
    file=strcat('PXI_noise_',comment,'.txt');
    save(file,'datos','-ascii');%salva los datos a fichero.
end