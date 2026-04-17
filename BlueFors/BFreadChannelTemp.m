function [Temp,varargout]=BFreadChannelTemp(ch)
%sanity check
url='http://192.168.2.104:5001/channels';
msg=urlread(url);
msg_str=loadjson(msg);
if ~msg_str.data{ch}.active
    error('Canal Inactivo');
end
url='http://192.168.2.104:5001/channel/measurement/latest';
msg=urlread(url);
msg_str=loadjson(msg);
while msg_str.channel_nr ~= ch
    msg=urlread(url);
    msg_str=loadjson(msg);
end
Temp=msg_str.temperature;
varargout{1}=msg_str;