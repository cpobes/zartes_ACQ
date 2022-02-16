function ok=BFsetPoint(Temp)
%%%basic function para fijar T bath.
Writeurl='ws://192.168.2.121:5002/heater/update';
%Readurl='ws://192.168.2.121:5002/heater';
if Temp>0.2 error('ojo a la set Temp');end
Tstr=num2str(Temp);
%wscRead=SimpleClient(Readurl);
wscWrite=SimpleClient(Writeurl);
message=strcat('{"heater_nr":4,"setpoint":',Tstr,'}');
wscWrite.send(message)
wscWrite.close()
pause(1200);%%%Stab Algorithm.
if Temp>0.07 pause(1000);end%%%extra wait for high temps.
Tstring=sprintf('%0.1fmK',Temp*1e3)
SETstr=strcat('tmp\T',Tstring,'.stb')
mkdir tmp
f = fopen(SETstr, 'w' )
fclose(f);
ok=1