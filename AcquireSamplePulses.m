function output=AcquireSamplePulses(varargin)
if nargin==0
    %min input options
    output.SourceCH=1;
    output.IV=[];
    output.pulsopt.SR=2e6;
    output.pulsopt.RL=20000;
    output.pulsopt.TriggerType='edge';
    output.OutputDir='.';
end
if nargin==2
    options=varargin{1};
    rps=varargin{2};
    %%%define ib50 from rpp
    %%%polarize TES.
    %%%define pulsopt.
    rangoTHR=0.5e-3;
    rango=1e3;
    IVaux=options.IV;
    ib50=BuildIbiasFromRp(IVaux,rps);
    SourceCH=options.SourceCH;
    pulsopt=options.pulsopt;
    mag=mag_init();
    signo=sign(ib50(1));
    Put_TES_toNormal_State_CH(mag,signo*500,SourceCH);
    mag_LoopResetCH(mag,SourceCH);
    multi=multi_init(0);
    pxi=PXI_init();
    tini=pulsopt.RL/pulsopt.SR/10;%sumimos disparo al 10%.
    mkdir(options.OutputDir)
    dc=[];Amp=[];Taue=[];
    for i=1:length(ib50)
        i
        mag_setImag_CH(mag,ib50(i),SourceCH);
        mag_LoopResetCH(mag,SourceCH);
        iaux=mag_readImag_CH(mag,SourceCH);
        %%%
        %%%Si la salida es estable, la fluctación en la
        %%%salida es menor de 1mV.
        rangoindx=1;
        while rango>rangoTHR%5e-4
            rango=multi_monitor(multi);
            'monitoring...'
            rangoindx=rangoindx+1;
            if rangoindx>25 break;end
        end
        str=strcat(num2str(iaux),'uA');
        try
            pulso=pxi_AcquirePulse(pxi,str,pulsopt);
        catch
            pxi_AbortAcquisition(pxi);
            pulso=zeros(2,pulsopt.RL);
        end
    if ~strcmp(options.OutputDir,'.')
            file=strcat('PXI_PulseSample_',str,'.txt');
            movefile(file,options.OutputDir);
    end
        %%%analisis
        %size(pulso), size(dc)
        dc(i)=mean(pulso(1:pulsopt.RL/20,2));
        Amp(i)=max(signo*medfilt1(pulso(:,2)-dc(i),10));
        aux=find(signo*(pulso(:,2)-dc(i))>Amp(i)/exp(1));
        Taue(i)=pulso(aux(end),1)-tini;%0.004=tini
    end
    output.rps=rps;
    output.dc=dc;
    output.Amp=Amp;
    output.Tau=Taue;
    fclose(multi)
    fclose(mag)
elseif nargin>0
    error('Wrong input number of arguments');
end
    
    