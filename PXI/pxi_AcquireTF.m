function TF=pxi_AcquireTF(pxi,varargin)
%%%

    Options.TimeOut=10;
    Options.channelList='0,1';
    
    [ConfStructs,waveformInfo]=pxi_Init_ConfigStructs();
    ConfStructs.Vertical.channelList='0,1';
    ConfStructs.Trigger.Type=6;
    
    ConfStructs.Horizontal.SR = 4e5;%%%2e5
    ConfStructs.Horizontal.RL = 4e5;%2e6.2e5
    
    pxi_ConfigureChannels(pxi,ConfStructs.Vertical);
    pxi_ConfigureHorizontal(pxi,ConfStructs.Horizontal);
    pxi_ConfigureTrigger(pxi,ConfStructs.Trigger)
    
dsa=hp_init();

if nargin==1
    excitacion=100;
else
    excitacion=varargin{1};
end
if(1)%%%White Noise version,
hp_WhiteNoise(dsa,excitacion);
[data,WfmI]=pxi_GetWaveForm(pxi,Options);
sk=skewness(data);
skTHR=0.5;
while abs(sk(3))>skTHR
    [data,WfmI]=pxi_GetWaveForm(pxi,Options);
    sk=skewness(data);
end
wind = hann(5000);
nov = 2500;
[txy,freqs]=tfestimate(data(:,2),data(:,3),wind,nov,2^14,ConfStructs.Horizontal.SR);%%%,[],[],2^14,ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR

n_avg=5;

for i=1:n_avg-1
    [data,WfmI]=pxi_GetWaveForm(pxi,Options);
    i
    sk=skewness(data);
    while abs(sk(3))>skTHR
        [data,WfmI]=pxi_GetWaveForm(pxi,Options);
        sk=skewness(data);
    end
    aux=tfestimate(data(:,2),data(:,3),wind,nov,2^14,ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR
    txy=txy+aux;
end
txy=txy/n_avg;
txy=medfilt1(txy,40);
 TF=[freqs real(txy) imag(txy)];
    if(1) %%%plot. señales.
        %[psd,freq]=PSD(data);
            auxhandle_1=findobj('name','PXI_TF');
            if isempty(auxhandle_1) figure('name','PXI_TF'); auxhandle_1=findobj('name','PXI_TF');else figure(auxhandle_1);end
        subplot(2,2,1)
        plot(data(:,1),data(:,2));
        grid on
        subplot(2,2,3)
        %loglog(freq,psd,'.-')
        plot(data(:,1),data(:,3));
        grid on
        subplot(1,2,2)
        plot(txy,'o-')
    end
   
end

if(0)%%%Sine SWEEP
    freq=logspace(4,5,21);%%%201
    hp_Source_ON(dsa);
    hp_sin_config(dsa,freq(1))
for i=1:length(freq)
    hp_sin_config(dsa,freq(i),1)
    
    if freq(i)>1e3, 
        ConfStructs.Horizontal.SR=1e7;
        pxi_ConfigureHorizontal(pxi,ConfStructs.Horizontal);
    end
    if freq(i)>1e4
        ConfStructs.Horizontal.RL=2e3;
        pxi_ConfigureHorizontal(pxi,ConfStructs.Horizontal);
    end
    pause(0.5);
    [data,WfmI]=pxi_GetWaveForm(pxi,Options);

    %X1=medfilt1(data(:,2),20);
    X2=medfilt1(data(:,3),20);
    %ps1=lsqcurvefit(@(p,t)p(1)*sin(p(2)*t+p(3)),[1 2*pi*freq(i) 1],data(:,1),X1);%X1
    %ps2=lsqcurvefit(@(p,t)p(1)*sin(p(2)*t+p(3))+p(4),[1 2*pi*freq(i) 1 0],data(:,1),X2);
    %TFamp=ps2(1)/ps1(1);
    %TFang=ps2(3)-ps1(3);
    
    ps1=lsqcurvefit(@(p,t)p(1)*sin(2*pi*freq(i)*t+p(2)),[1 1],data(:,1),data(:,2));%X1
    ps2=lsqcurvefit(@(p,t)p(1)*sin(2*pi*freq(i)*t+p(2))+p(3),[1 1 0],data(:,1),X2);
    TFamp=ps2(1)/ps1(1);
    TFang=ps2(2)-ps1(2);
    %TFamp=range(X2)/range(X1); %%approximate estimate of amplitude ratio
    %TFang=acos(dot(X1,X2)/(norm(X1)*norm(X2)));%%%aprox estimate of phase difference

    [ps1(2) ps2(2)]/(2*pi)
    Re(i)=TFamp*cos(TFang);
    Imag(i)=TFamp*sin(TFang);
    
    if(1) %%%plot?
        %[psd,freq]=PSD(data);
            auxhandle_1=findobj('name','PXI_TF');
            if isempty(auxhandle_1) figure('name','PXI_TF'); else figure(auxhandle_1);end
        subplot(2,2,1)
        hold off
        plot(data(:,1),data(:,2));hold on
        %plot(data(:,1),ps1(1)*sin(ps1(2)*data(:,1)+ps1(3)),'r');
        plot(data(:,1),ps1(1)*sin(2*pi*freq(i)*data(:,1)+ps1(2)),'r');
        grid on
        subplot(2,2,3)
%         loglog(freq,psd,'.-')
        hold off
        plot(data(:,1),data(:,3));hold on,%data(:,3)
        %plot(data(:,1),ps2(1)*sin(ps2(2)*data(:,1)+ps2(3))+ps2(4),'r');
        plot(data(:,1),ps2(1)*sin(2*pi*freq(i)*data(:,1)+ps2(2))+ps2(3),'r');
        grid on
        subplot(1,2,2)
        plot(Re,Imag,'o-')
    end
    

    
    %TF(i)=TFamp*(cos(TFang)+1i*sin(TFang));
end
TF=[freq' Re' Imag'];
end
hp_Source_OFF(dsa);


% RL=pxi.Horizontal.Actual_Record_Length;
% SR=pxi.Horizontal.Actual_Sample_Rate;
% DF=SR/RL;
%freq=DF:DF:SR/2;
%freq=1:length(txy);

%size(freq),size(txy),size(data)
%TF=[freq' real(txy) imag(txy)];

fclose(dsa);delete(dsa);