function [ConfStructs,waveformInfo]=pxi_Init_ConfigStructs()
%%%%Función para crear las estructuras de configuración con valores por
%%%%defecto, para no tener que crearlas campo a campo.

%%%% Horizontal Configuration
ConfStructs.Horizontal.SR = 2e5;
ConfStructs.Horizontal.RL = 2e4;
ConfStructs.Horizontal.RefPos = 20;

%%%% Vertical Configuration
ConfStructs.Vertical.ChannelList='0,1';
ConfStructs.Vertical.Range=0.0025;
ConfStructs.Vertical.Coupling='dc';
ConfStructs.Vertical.ProbeAttenuation=1;
ConfStructs.Vertical.offset=0;
ConfStructs.Vertical.Enabled=1;

%%% Trigger Configuration
ConfStructs.Trigger.Source='1'; 
ConfStructs.Trigger.Type=1;
ConfStructs.Trigger.Slope=0;%%%0:Neg, 1:Pos
ConfStructs.Trigger.Level=-0.05; %%%%Habrá que resetear el lazo del Squid pq el ch1 se acopla en DC.
ConfStructs.Trigger.Coupling=1;%%%DC=1; AC=0;?. '0' da error.
ConfStructs.Trigger.Holdoff=0;
ConfStructs.Trigger.Delay=0; 

if length(ConfStructs.Vertical.ChannelList)==1 nchannels=1;else nchannels=2;end
for i = 1:nchannels
    waveformInfo(i).absoluteInitialX = 0;
    waveformInfo(i).relativeInitialX = 0;
    waveformInfo(i).xIncrement = 0;
    waveformInfo(i).actualSamples = 0;
    waveformInfo(i).offset = 0;
    waveformInfo(i).gain = 0;
    waveformInfo(i).reserved1 = 0;
    waveformInfo(i).reserved2 = 0;
end 
