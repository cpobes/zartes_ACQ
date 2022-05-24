function pxi_auto_acq_POS_NEG(IZvaluesP,varargin)
%%%%Pasar los IZvalues positivos y negativos

PXIopt.TF=1;
PXIopt.Noise=1;
PXIopt.Pulses=0;
IZvaluesN=-IZvaluesP;
for i=1:nargin-1
    if isstruct(varargin{i}) PXIopt=varargin{i};end
    if isnumeric(varargin{i}) IZvaluesN=varargin{1};end
end    
pxi_auto_acq(IZvaluesP,PXIopt);

%if nargin==1 IZvaluesN=-IZvaluesP; else IZvaluesN=varargin{1};end
d=pwd;
%temp=regexp(d,'\d*mK','match');
temp=regexp(d,'\d*.?\d*mK','match');%%%Regexp correcta para reconocer tanto 50mK como 50.0mK
mkdir(strcat('../Negative Bias/',temp{1}));%%%Crea el directorio para las Z(w) con Ibias negativa.
cd(strcat('../Negative Bias/',temp{1}));
pxi_auto_acq(IZvaluesN,PXIopt);
cd('../..')