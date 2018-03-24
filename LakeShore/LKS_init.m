function lks=LKS_init(varargin)
%Función para inicializar una sesión con la fuente de corriente K220.
% Por defecto esta en la dir=1, subdir=2.
if nargin == 0
    gpib_dir=0;
else
    gpib_dir=varargin{1};
end

%dsa=instrfind('Status','open');%ojo! puede haber otros devices abiertos!
lks=instrfind('type','gpib','Status','open','primaryaddress',12);
if isempty(lks)    
    lks=gpib('ni',gpib_dir,12);%dir:1 puede cambiar
    fopen(lks); %cerrar al final.
end

device=query(lks,'*IDN?');%esta instruccion es más directa.