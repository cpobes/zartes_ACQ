function pxi_ConfigureTrigger(pxi,conf)
%%%Función para configurar el trigger.
%%% type >> get(pxi.Triggering) for options.
%%% type >> set(pxi.Triggering) for options with alternatives.
%%% (VAL_NO_SOURCE for none).
%%% Modos pxi.Triggering.Trigger_Type:
%%%  -Edge: 1
%%%  -Immediate: 6
%%%  -Digital: 1002
%%%  -Histeresis: 1001
%%%  -Software: 1004
%%%  -Window: 1003
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
