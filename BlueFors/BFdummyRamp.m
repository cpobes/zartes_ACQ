function BFdummyRamp(varargin)
try
    config=BFgetHeaterConfig();
    Wstep=200e-9;%20nW/seg
    config.power=config.power+Wstep;
    BFconfigure(config);
catch
    warning('Posible error de comunicaci�n con el BF');
end