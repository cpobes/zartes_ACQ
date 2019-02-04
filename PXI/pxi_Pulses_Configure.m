function pxi_Pulses_Configure(pxi,varargin)
%%%Función para configurar la PXI para adquirir pulsos. Duracion max 2ms.

Confs=pxi_Init_ConfigStructs;

HorizontalConf=Confs.Horizontal;%%%Aumentamos SR.
%%%Ventana digitalizada= RL/SR.(a 5MS/S y 25KS son 5ms.)
HorizontalConf.SR = 4e5;%%%def:5e6
HorizontalConf.RL = 4.e5; %%%def:25e3; 2e4 cubre los 2mseg a 10MS/S pero si pa RefPos=20% no se coge todo el pulso.
pxi_ConfigureHorizontal(pxi,HorizontalConf)

VerticalConf=Confs.Vertical;%%%El init ya esta bien.
VerticalConf.Range=1;
pxi_ConfigureChannels(pxi,VerticalConf)

TriggerConf=Confs.Trigger;
TriggerConf.Type=1;%%%%El trigger Edge no funciona.

%%% si tenemos modulo trigger.
TriggerConf.Level=1;
TriggerConf.Slope=1;
TriggerConf.Coupling=1;

if nargin>1
    conf=varargin{1};
    if isfield(conf,'Level') TriggerConf.Level=conf.Level;end
end

pxi_ConfigureTrigger(pxi,TriggerConf);

%TriggerConf.Source='NISCOPE_VAL_EXTERNAL';
set(get(pxi,'triggering'),'trigger_source','NISCOPE_VAL_EXTERNAL');%%%%Hacerlo a través de ConfigureTrigger da error!!!pq?!

if TriggerConf.Type==1003.0
    HighLevel=TriggerConf.Level;
    LowLevel=HighLevel-0.1;
    set(pxi.Triggeringtriggerwindow,'High_Window_Level',HighLevel);
    set(pxi.Triggeringtriggerwindow,'Low_Window_Level',LowLevel);
end

