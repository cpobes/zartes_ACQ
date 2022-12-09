function [Temp,varargout]=BFreadMCTemp()
url='http://192.168.2.121:5001/channel/measurement/latest'
msg=urlread(url);
msg_str=loadjson(msg);
while msg_str.channel_nr ~= 6
    msg=urlread(url);
    msg_str=loadjson(msg);
end
Temp=msg_str.temperature;
varargout{1}=msg_str;