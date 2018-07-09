function TF=pxi_AcquireTF(pxi)
%%%

    Options.TimeOut=10;
    Options.channelList='0,1';
    
    [ConfStructs,waveformInfo]=pxi_Init_ConfigStructs();
    ConfStructs.Vertical.channelList='0,1';
    ConfStructs.Trigger.Type=6;
    
    ConfStructs.Horizontal.SR = 2e5;
    ConfStructs.Horizontal.RL=2e4;%2e6
    
    pxi_ConfigureChannels(pxi,ConfStructs.Vertical);
    pxi_ConfigureHorizontal(pxi,ConfStructs.Horizontal);
    pxi_ConfigureTrigger(pxi,ConfStructs.Trigger)
    
dsa=hp_init(0);

if(1)%%%White Noise version,
hp_WhiteNoise(dsa,100);
[data,WfmI]=pxi_GetWaveForm(pxi,Options);
[txy,freqs]=tfestimate(data(:,2),data(:,3));%%%,[],[],128,ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR
n_avg=50;
for i=1:n_avg-1
    aux=tfestimate(data(:,2),data(:,3));%%%,[],[],128,ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR
    txy=txy+aux;
end
txy=txy/n_avg;
txy=medfilt1(txy,40);
 TF=[freqs real(txy) imag(txy)];
    if(1) %%%plot. señales.
        %[psd,freq]=PSD(data);
            auxhandle_1=findobj('name','PXI_TF');
            if isempty(auxhandle_1) figure('name','PXI_TF'); else figure(auxhandle_1);end
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
    freq=logspace(1,5,201);
    hp_Source_ON(dsa);
for i=1:length(freq)
    hp_sin_config(dsa,freq(i))
    
    if freq(i)>1e3, 
        ConfStructs.Horizontal.SR=1e7;
        pxi_ConfigureHorizontal(pxi,ConfStructs.Horizontal);
    end
    if freq(i)>1e4
        ConfStructs.Horizontal.RL=2e3;
        pxi_ConfigureHorizontal(pxi,ConfStructs.Horizontal);
    end
    pause(1);
    [data,WfmI]=pxi_GetWaveForm(pxi,Options);
    
    TFamp=range(data(:,3))/range(data(:,2)); %%approximate estimate of amplitude ratio
    TFang=acos(dot(data(:,2),data(:,3))/(norm(data(:,2))*norm(data(:,3))));%%%aprox estimate of phase difference
    Re(i)=TFamp*cos(TFang);
    Imag(i)=TFamp*sin(TFang);
    
    if(1) %%%plot?
        %[psd,freq]=PSD(data);
            auxhandle_1=findobj('name','PXI_TF');
            if isempty(auxhandle_1) figure('name','PXI_TF'); else figure(auxhandle_1);end
        subplot(2,2,1)
        plot(data(:,1),data(:,2));
        grid on
        subplot(2,2,3)
        %loglog(freq,psd,'.-')
        plot(data(:,1),data(:,3));
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