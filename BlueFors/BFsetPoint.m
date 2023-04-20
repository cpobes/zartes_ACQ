function [ok,varargout]=BFsetPoint(Temp,varargin)
%%%basic function para fijar T bath.
Writeurl='ws://192.168.2.121:5002/heater/update';
%Readurl='ws://192.168.2.121:5002/heater';
if Temp>0.2 error('ojo a la set Temp');end
%Tstr=num2str(Temp);
%wscRead=SimpleClient(Readurl);

if Temp<=0.080 %0.050
    P=0.01;
    I=250;
    D=0;
else
    P=0.05;
    I=100;
    D=0;
end
if nargin==1
    config=BFgetHeaterConfig();
    config.control_algorithm_settings.proportional=P;
    config.control_algorithm_settings.integral=I;
    config.control_algorithm_settings.derivative=D;
end
if nargin>1
    config=varargin{1};%puede ser struct o filename
end
if nargin>1 & isstruct(config)
    if isfield(varargin{1},'P')%para pasar el pid como estructura directamente.
        pid=varargin{1};
        config=BFgetHeaterConfig;
        config.control_algorithm_settings.proportional=pid.P;
        config.control_algorithm_settings.integral=pid.I;
        config.control_algorithm_settings.derivative=pid.D;
    end
elseif nargin>1 & ischar(config)%para pasar configuracion completa con .json
    config=loadjson(config);
end
%%%runs PID
%P=0.3;I=40;%%%pruebas PID. run001:P,I=(0.1,80).r2:(0.05,150).
%r003:(0.01,250). r004:(3,750).r5:(0.3,40).

%Para leer heater:
%message=strcat('{"heater_nr":4}');
%BFconfigure(config);
%message=strcat('{"heater_nr":4,"setpoint":',Tstr,'}')
%message=strcat('{"heater_nr":4,"pid_mode":1,"active":true,"setpoint":',Tstr,',"control_algorithm_settings":{"proportional":',num2str(P),',"integral":',num2str(I),',"derivative":0','}}')

%return %debug
%if Temp>0.07 pause(1000);end%%%extra wait for high temps.
Tstring=sprintf('%0.1fmK',Temp*1e3);
SETstr=strcat('tmp\T',Tstring,'.stb');
T0=BFreadMCTemp();
boolmonitor=0;
if isfield(config,'boolmonitor')
    boolmonitor=config.boolmonitor;
end
if exist(SETstr,'file')&&(abs(T0-Temp)<1e-3)
    %do nothing. Es para no esperar ni cambiar conf cuando el BF esta ya a
    %la temp deseada. Ojo si no lo está.
else
    if config.pid_mode %si estamos en modo PID pasamos el setpoint
        config.setpoint=Temp;
        BFconfigure(config);
%         wscWrite=SimpleClient(Writeurl);
%         wscWrite.send(message)
%         wscWrite.close()
    end
    if Temp>0 & boolmonitor
        %pause(1800);
        %%%Stab Algorithm. wait time. normal run:1200. PIDs 1800.
        outdata=BFmonitorMCTemp(Temp);
        fname=strcat('TsetLogData_',num2str(round(now*86400)),'_from',num2str(round(T0*1e3)*1e-3),'_to',num2str(Temp),'K.txt');
        writetable(struct2table(outdata),fname,'writevariablenames',0,'delimiter',' ');
        %save(fname,'outdata','-ascii');
    end
    
    mkdir tmp
    f = fopen(SETstr, 'w' );
    fclose(f);
end
ok=1;
if exist('outdata') varargout{1}=outdata; end