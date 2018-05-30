function pxi_ConfigureChannels(pxi,ConfigureOptions)
%%%Función para configurar la escala vertical de los canales y acoplos.
%%%ConfigureOptions es una estructura con todos los campos necesarios. Si
%%%ChannelList es '0,1' se aplica a los dos canales, si es '0' o '1', sólo
%%%a ese. Habilitar o deshabilitar el canal es poner Enabled=0,1. Y el
%%%coupling=0 es 'AC' y coupling=1 es 'DC'.
ChannelList=ConfigureOptions.ChannelList;
Range=ConfigureOptions.Range;
offset=ConfigureOptions.offset;
if strcmpi(ConfigureOptions.Coupling,'AC') Coupling=0;elseif strcmpi(ConfigureOptions.Coupling,'DC') Coupling=1;end
ProbeAttenuation=ConfigureOptions.ProbeAttenuation;
Enabled=ConfigureOptions.Enabled;

invoke(pxi.configurationfunctionsvertical,'configurevertical',ChannelList,Range,offset,Coupling,ProbeAttenuation,Enabled)