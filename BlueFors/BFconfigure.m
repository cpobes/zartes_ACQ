function BFconfigure(varargin)
%%%Funcion para configurar el heater del BF. En realidad se podría
%%%generalizar para configurar también termómetros, etc.
Writeurl='ws://192.168.2.121:5002/heater/update';
config=BFgetHeaterConfig();
Tstr=num2str(config.setpoint);
default_msg=strcat('{"heater_nr":4,"pid_mode":1,"active":true,"setpoint":',Tstr,'}');
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
wscWrite=SimpleClient(Writeurl);
if nargin==0 
    wscWrite.send(default_msg)
    disp('default config')
end
if nargin>0
    if config.active active='true';else active='false';end%active=0 para desactivar
    pid_mode=num2str(config.pid_mode);%pid_mode=0 para manual
    Tstr=num2str(config.setpoint);
    P=config.control_algorithm_settings.proportional;
    I=config.control_algorithm_settings.integral;
    D=config.control_algorithm_settings.derivative;
    message=strcat('{"heater_nr":4,"pid_mode":',pid_mode,',"active":',active,',"setpoint":',Tstr,',"control_algorithm_settings":{"proportional":',num2str(P),',"integral":',num2str(I),',"derivative":',num2str(D),'}}');
    if isfield(config,'power')
        message=strcat('{"heater_nr":4,"pid_mode":',pid_mode,',"active":',active,',"setpoint":',Tstr,',"power":',num2str(config.power),',"control_algorithm_settings":{"proportional":',num2str(P),',"integral":',num2str(I),',"derivative":',num2str(D),'}}');
    end
    wscWrite.send(message)
end
wscWrite.close()