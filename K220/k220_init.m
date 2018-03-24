function k220=k220_init(varargin)
%Función para inicializar una sesión con la fuente de corriente K220.
% Por defecto esta en la dir=1, subdir=2.
if nargin == 0
    gpib_dir=1;
else
    gpib_dir=varargin{1};
end

%dsa=instrfind('Status','open');%ojo! puede haber otros devices abiertos!
k220=instrfind('type','gpib','boardindex',1,'primaryaddress',2);
if isempty(k220)    
    k220=gpib('ni',gpib_dir,2);%dir:1 puede cambiar
    fopen(k220); %cerrar al final.
elseif strcmp(k220(1).Status,'closed')
    fopen(k220(1));
end

device=query(k220,'*IDN?');%esta instruccion es más directa.