function BFdummyRamp(varargin)
config=BFgetHeaterConfig();
Wstep=2e-9;
config.power=config.power+Wstep;
BFconfigure(config);