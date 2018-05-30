function [data,WfmI]=pxi_GetWaveForm(pxi,Options)
%%Función para descargar una captura y la informacion asociada a un vector

numSamples=get(get(pxi,'horizontal'),'min_number_of_points');
TimeOut=Options.TimeOut;
channelList=Options.channelList;
L=length(channelList);
if L==1, numChannels=1;else numChannels=2;end

for i = 1:numChannels %%%Inicializamos la Info.
    waveformInfo(i).absoluteInitialX = 0;
    waveformInfo(i).relativeInitialX = 0;
    waveformInfo(i).xIncrement = 0;
    waveformInfo(i).actualSamples = 0;
    waveformInfo(i).offset = 0;
    waveformInfo(i).gain = 0;
    waveformInfo(i).reserved1 = 0;
    waveformInfo(i).reserved2 = 0;
end 
waveformArray=zeros(1,numSamples*numChannels);%%%Prealojamos espacio.

invoke(pxi.Acquisition, 'initiateacquisition'); %%%Pued ir aquí o fuera.
[Wfm, WfmI] = invoke(pxi.Acquisition, 'fetch', channelList,TimeOut, numSamples, waveformArray, waveformInfo); %%

%size(Wfm)

DT=WfmI.xIncrement;
L=WfmI.actualSamples;
data(:,1)=(0:L-1)*DT;
data(:,2)=Wfm(1:L);
if numChannels==2 data(:,3)=Wfm(L+1:end);end
