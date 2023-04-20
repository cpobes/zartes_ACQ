function config=BFgetHeaterConfig(varargin)
Readurl='http://192.168.2.121:5001/heaters';
actualconfig=webread(Readurl);
Heater=4;
if nargin>0
    Heater=varargin{1};
end
for i=1:length(actualconfig.data)
    if actualconfig.data(i).heater_nr==Heater
        config=actualconfig.data(i);
    end
end