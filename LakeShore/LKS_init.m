function lks=LKS_init(varargin)
%Función para inicializar una sesión con la fuente de corriente K220.
% Por defecto esta en la dir=1, subdir=2.
LKS_Primary_Address=12;

if nargin == 0%obsoleto.
    gpib_dir=0;
else
    gpib_dir=varargin{1};
end

%robust gpib_dir find.
x=instrhwinfo('visa','ni');
y=regexp(x.ObjectConstructorName,strcat('GPIB(?<gpib>\d)::',num2str(LKS_Primary_Address),'::'),'names');
y=y{~cellfun(@isempty,y)};
gpib_dir=str2num(y.gpib);

%dsa=instrfind('Status','open');%ojo! puede haber otros devices abiertos!
lks=instrfind('type','gpib','Status','open','primaryaddress',LKS_Primary_Address);
if isempty(lks)    
    lks=gpib('ni',gpib_dir,LKS_Primary_Address);%dir:1 puede cambiar
    fopen(lks); %cerrar al final.
end

set(lks,'timeout',1)

device=query(lks,'*IDN?');%esta instruccion es más directa.