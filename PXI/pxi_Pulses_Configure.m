function pxi_Pulses_Configure(pxi,varargin)
%%%Función para configurar la PXI para adquirir pulsos. Duracion max 2ms.

Confs=pxi_Init_ConfigStructs;

HorizontalConf=Confs.Horizontal;%%%Aumentamos SR.
%%%Ventana digitalizada= RL/SR.(a 5MS/S y 25KS son 5ms.)
HorizontalConf.RL = 2000;%156250; %%%def:25e3; 2e4 cubre los 2mseg a 10MS/S pero si pa RefPos=20% no se coge todo el pulso.
HorizontalConf.SR = 1e5;%156250;%%%def:5e6(run003 2e5, RL=4e3)

TriggerConf=Confs.Trigger;

if nargin>1 
    conf=varargin{1};
    if isfield(conf,'RL') HorizontalConf.RL =conf.RL;end
    if isfield(conf,'SR') HorizontalConf.SR =conf.SR;end
    if isfield(conf,'TriggerType') 
        switch conf.TriggerType
            case 'edge'
                TriggerConf.Type=1;
            case 'immediate'
                TriggerConf.Type=6;
            otherwise
                error('Wrong Trigger Type');
        end
    end
end

pxi_ConfigureHorizontal(pxi,HorizontalConf)

VerticalConf=Confs.Vertical;%%%El init ya esta bien.
VerticalConf.Range=1;
pxi_ConfigureChannels(pxi,VerticalConf)

if nargin==1
    TriggerConf.Type=1;%%%%El trigger Edge no funciona.1:edge. 6:immediate.
end

%%% si tenemos modulo trigger.
%TriggerConf.Source='0';%%%
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
%set(get(pxi,'triggering'),'trigger_source','NISCOPE_VAL_RTSI_0');

if TriggerConf.Type==1003.0
    HighLevel=TriggerConf.Level;
    %HighLevel=-0.03
    LowLevel=HighLevel-0.1;
    set(pxi.Triggeringtriggerwindow,'High_Window_Level',HighLevel);
    set(pxi.Triggeringtriggerwindow,'Low_Window_Level',LowLevel);
end

