function pxi_ConfigureTrigger(pxi,conf)
%%%Función para configurar el trigger.

if conf.Type==1 %%%modo edge  %%%%pxi.Triggering.Trigger_Type
    Source=conf.Source;
    Level=conf.Level;
    Slope=conf.Slope;
    Coupling=conf.Coupling;
    Holdoff=conf.Holdoff;
    Delay=0;%%%conf.Delay;
    
    invoke(pxi.Configurationfunctionstrigger,'configuretriggeredge',Source,Level,Slope,Coupling,Holdoff,Delay);
elseif conf.Type==6  %%%modo immediate
    invoke(pxi.Configurationfunctionstrigger,'configuretriggerimmediate');
end
