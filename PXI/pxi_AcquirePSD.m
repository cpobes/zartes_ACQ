function datos=pxi_AcquirePSD(pxi,varargin)
%%%Función para adquirir y salvar en fichero un espectro PSD con la
%%%PXI. Asume que la tarjeta está ya correctamente configurada. Se pasa
%%%como argumento el handle al instrumento y un string para identificar el
%%%nombre del fichero.

pxi_Noise_Configure(pxi);

%%%configuracion subsampleo. Pasar como opcion
subsampling.bool=0;
subsampling.NpointsDec=100;

boolsubsampling=subsampling.bool;
NpointsDec=subsampling.NpointsDec;
%get(get(pxi,'horizontal'),'Actual_Sample_Rate')
%get(get(pxi,'horizontal'),'actual_record_length')

Options.TimeOut=5;
Options.channelList='1';

[data,WfmI]=pxi_GetWaveForm(pxi,Options);
rg=skewness(data);

if nargin==3 circuit=varargin{2};end%%%para que si no lo uso?

ix=0;
while abs(rg(2))>0.6 %%%%%Condición para filtrar lineas de base con pulsos! 0.004
    if ix>10, break;end
    [data,WfmI]=pxi_GetWaveForm(pxi,Options);
    rg=skewness(data);
    ix=ix+1;
end
[psd,freq]=PSD(data);

%size(freq), size(psd)

if(boolsubsampling)%%%subsampleo?
    if freq(1)==0, 
        logfmin=log10(freq(2));
    else
        logfmin=log10(freq(1));
    end%%%%Ojo, pq PSD hace fmin=0 siempre.?!
    logfmax=log10(freq(end));
    Ndec=logfmax-logfmin;
    %NpointsDec=200;%%%
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
    %hold off
    vrhz=medfilt1(sqrt(psd),10);
    loglog(freq(:),vrhz(:),'.-')
    ylim([1e-7 1e-4]),hold on
    %semilogx(freq,10*log10(psd),'.-')
    grid on
    %%%
%     noisemodel=SnoiseModel(circuit,0.04);
%     noisemodel=NnoiseModel(circuit,0.18);
%     hold on
%     f=logspace(0,6,1000);
%     loglog(f,I2V(noisemodel,circuit),'r')
    %semilogx(logspace(0,6),20*log10(I2V(noisemodel,circuit)),'r')
end

datos(:,1)=freq;
datos(:,2)=sqrt(psd);

if nargin>1
    comment=varargin{1};
    file=strcat('PXI_noise_',comment,'.txt');
    save(file,'datos','-ascii');%salva los datos a fichero.
end