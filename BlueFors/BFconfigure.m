function BFconfigure(varargin)
%%%Funcion para configurar el heater del BF. En realidad se podría
%%%generalizar para configurar también termómetros, etc.
Writeurl='ws://192.168.2.121:5002/heater/update';
default_config='{"heater_nr":4,"pid_mode":1,"active":true}';
for i=1:length(varargin)
    if ischar(varargin{i})
    if strfind(varargin{i},'json')
        config=loadjson(varargin{i});
    end
    end
    if isstruct(varargin{i})
        config=varargin{i};
    end
end
if nargin==0 config=default_config;end
if config.active active='true';else active='false';end%active=0 para desactivar
pid_mode=num2str(config.pid_mode);%pid_mode=0 para manual
Tstr=num2str(config.setpoint);
P=config.control_algorithm_settings.proportional;
I=config.control_algorithm_settings.integral;
D=config.control_algorithm_settings.derivative;
message=strcat('{"heater_nr":4,"pid_mode":',pid_mode,',"active":',active,',"setpoint":',Tstr,',"control_algorithm_settings":{"proportional":',num2str(P),',"integral":',num2str(I),',"derivative":',num2str(D),'}}');
wscWrite=SimpleClient(Writeurl);
wscWrite.send(message)
wscWrite.close()