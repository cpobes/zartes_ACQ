function dsa=hp_init(varargin)
%Función para inicializar una sesión con el HP.
% 
if nargin == 0
    gpib_dir=1;
else
    gpib_dir=varargin{1};
end

%dsa=instrfind('Status','open');%ojo! puede haber otros devices abiertos!
dsa=instrfind('type','gpib','Status','open','primaryaddress',11);
if isempty(dsa)    
    dsa=gpib('ni',gpib_dir,11);%dir:1 puede cambiar
    fopen(dsa); %cerrar al final.
end
%instrfind; %muestra los instrumentos y su estado.

%fprintf(dsa,'ID?');
%device=fscanf(dsa)%devuelve HP3562A. Permite comprobar si estamos leyendo el 
device=query(dsa,'ID?');%esta instruccion es más directa.
if ~strcmpi('HP3562A',device(1:end-2)), return;end %dispositivo correcto?