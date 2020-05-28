function pxi_Noise_Configure(pxi)
%%%%Función para configurar la pxi para adquirir ruido en 1Hz-100KHz window

Confs=pxi_Init_ConfigStructs;

HorizontalConf=Confs.Horizontal;%%%El init ya esta bien
%%%Xifu config RL=8192, SR=156250;
HorizontalConf.RL=2e5;%2e5;%%%2e5 para fi=1Hz, RL=2e4 para fi=10Hz.
HorizontalConf.SR=2e5;%%%100000 def.
pxi_ConfigureHorizontal(pxi,HorizontalConf)

VerticalConf=Confs.Vertical;%%%El init ya esta bien.
pxi_ConfigureChannels(pxi,VerticalConf)

TriggerConf=Confs.Trigger;%%%Init configura en Edge.
TriggerConf.Type=6;
TriggerConf.Source='NISCOPE_VAL_IMMEDIATE';
pxi_ConfigureTrigger(pxi,TriggerConf)



