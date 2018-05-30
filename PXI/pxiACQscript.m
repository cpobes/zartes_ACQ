%pxiacqscript

numSamples=get(get(scope,'horizontal'),'min_number_of_points')
waveformArray=zeros(1,numSamples);
TimeOut=5;
channelList='0';
data=[];
for i=1:10
invoke(scope.Acquisition, 'initiateacquisition')
[waveformArray, waveformInfo] = invoke(scope.Acquisition, 'fetch', channelList,TimeOut, numSamples, waveformArray, waveformInfo); %%

DT=waveformInfo.xIncrement;
L=waveformInfo.actualSamples
data(:,1)=(0:L-1)*DT;
data(:,2)=waveformArray;
[psd,freq]=PSD(data);

subplot(2,1,1)
plot(waveformArray);
grid on
subplot(2,1,2)
%loglog(freq,psd,'.-')
semilogx(freq,10*log10(psd),'.-')
grid on
pause(1)

end