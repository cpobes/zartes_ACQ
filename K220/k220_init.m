function k220=k220_init(varargin)
%Función para inicializar una sesión con la fuente de corriente K220.
% Por defecto esta en la dir=1, subdir=2.
K220_Primary_Address=2;%leer from .json?
if nargin == 0
    gpib_dir=1;
else
    gpib_dir=varargin{1};
end

%dsa=instrfind('Status','open');%ojo! puede haber otros devices abiertos!
k220=instrfind('type','gpib','boardindex',gpib_dir,'primaryaddress',K220_Primary_Address);
if isempty(k220)    
    k220=gpib('ni',gpib_dir,K220_Primary_Address);%dir:1 puede cambiar
    fopen(k220); %cerrar al final.
elseif strcmp(k220(1).Status,'closed')
    fopen(k220(1));
end
k220.EOSMode='write'; %%%Esta instruccion parece necesaria 
%%%%antes de eso, aunque se establece comunicación, no responde 
%%%% a los comandos y da error o bien de 'rem' o 'ldd'.
%device=query(k220,'*IDN?');%esta instruccion es más directa.