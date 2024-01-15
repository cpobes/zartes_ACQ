function datos=pxi_AcquirePSD(pxi,varargin)
%%%Función para adquirir y salvar en fichero un espectro PSD con la
%%%PXI. Asume que la tarjeta está ya correctamente configurada. Se pasa
%%%como argumento el handle al instrumento y un string para identificar el
%%%nombre del fichero.

%default config
opt.RL=2e5;%def: 2e5
opt.SR=2e5;%2e5
comment='test';
%%%configuracion subsampleo. Pasar como opcion
subsampling.bool=0;
subsampling.NpointsDec=100;
savebool=0;
for i=1:length(varargin)
    if isstruct(varargin{i}) opt=varargin{i};savebool=0;end
    if ischar(varargin{i}) comment=varargin{i};savebool=1;end%
end

pxi_Noise_Configure(pxi,opt);

if isfield(opt,'subsampling')
    subsampling.bool=opt.subsampling.bool;
    subsampling.NpointsDec=opt.subsampling.NpointsDec;
end
boolsubsampling=subsampling.bool;
NpointsDec=subsampling.NpointsDec;
%get(get(pxi,'horizontal'),'Actual_Sample_Rate')
%get(get(pxi,'horizontal'),'actual_record_length')

Options.TimeOut=5;
Options.channelList='1';

[data,WfmI]=pxi_GetWaveForm(pxi,Options);
rg=skewness(data);

ix=0;
while abs(rg(2))>0.6 %%%%%Condición para filtrar lineas de base con pulsos! 0.004
    if ix>10, disp('Bucle sobre GetWaveForm en PSD ejecutado 10 veces');break;end
    [data,WfmI]=pxi_GetWaveForm(pxi,Options);
    rg=skewness(data);
    ix=ix+1;
end
[psd,freq]=PSD(data);

%size(freq), size(psd)

if(boolsubsampling)%%%subsampleo?
    %'subsampleo'
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

medfiltWindow=10;%%%<-Esto deberia ser configurable.
ylimRange=[1e-7 1e-5];
boolplot=1;
if(boolplot) %%%plot?
    auxhandle=findobj('name','PXI_PSD');
    if isempty(auxhandle) 
        auxhandle=figure('name','PXI_PSD'); 
    else figure(auxhandle);
    end
    subplot(2,1,1)
    plot(data(:,1),data(:,2));
    grid on
    subplot(2,1,2)
    %hold off
    vrhz=medfilt1(sqrt(psd),medfiltWindow);
    loglog(freq(:),vrhz(:),'.-','linewidth',2)
    ylim(ylimRange),hold on
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
if(savebool)
    file=strcat('PXI_noise_',comment,'.txt');
    save(file,'datos','-ascii');%salva los datos a fichero. Esto debería ser también configurable.
end
