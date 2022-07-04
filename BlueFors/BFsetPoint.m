function ok=BFsetPoint(Temp)
%%%basic function para fijar T bath.
Writeurl='ws://192.168.2.121:5002/heater/update';
%Readurl='ws://192.168.2.121:5002/heater';
if Temp>0.2 error('ojo a la set Temp');end
Tstr=num2str(Temp);
%wscRead=SimpleClient(Readurl);

if Temp<=0.050
    P=0.01;
    I=250;
else
    P=0.05;
    I=100;
end
%P=0.3;I=747;%%%prueba
%message=strcat('{"heater_nr":4,"setpoint":',Tstr,'}')
message=strcat('{"heater_nr":4,"setpoint":',Tstr,',"control_algorithm_settings":{"proportional":',num2str(P),',"integral":',num2str(I),',"derivative":0','}}')

%return %debug
%if Temp>0.07 pause(1000);end%%%extra wait for high temps.
Tstring=sprintf('%0.1fmK',Temp*1e3)
SETstr=strcat('tmp\T',Tstring,'.stb')
if exist(SETstr,'file')
    %do nothing. Es para no esperar ni cambiar conf cuando el BF esta ya a
    %la temp deseada. Ojo si no lo est�.
else
    wscWrite=SimpleClient(Writeurl);
    wscWrite.send(message)
    wscWrite.close()
    pause(1200);%%%Stab Algorithm.
    mkdir tmp
    f = fopen(SETstr, 'w' )
    fclose(f);
end
ok=1