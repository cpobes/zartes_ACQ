function config=BFgetHeaterConfig(varargin)
Readurl='http://192.168.2.121:5001/heaters';
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