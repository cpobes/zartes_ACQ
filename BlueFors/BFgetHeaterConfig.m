function config=BFgetHeaterConfig(varargin)
Readurl='http://192.168.2.104:5001/heaters';%121->104.
%actualconfig=webread(Readurl);%errores de comunicacion?
xx=urlread(Readurl);
actualconfig=loadjson(xx);
Heater=4;
if nargin>0
    Heater=varargin{1};
end
for i=1:length(actualconfig.data)
    %if actualconfig.data(i).heater_nr==Heater%webread
    if actualconfig.data{i}.heater_nr==Heater
        %config=actualconfig.data(i);%webread
        config=actualconfig.data{i};
    end
end