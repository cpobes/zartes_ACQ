function dsa=hp_init(varargin)
%Función para inicializar una sesión con el HP.
% 
DSA_Primary_Address=11;%leer from .json?

if nargin == 0%obsoleto
    gpib_dir=1;
else
    gpib_dir=varargin{1};
end

%robust gpib_dir find.
x=instrhwinfo('visa','ni');
y=regexp(x.ObjectConstructorName,strcat('GPIB(?<gpib>\d)::',num2str(DSA_Primary_Address),'::'),'names');
y=y{~cellfun(@isempty,y)};
gpib_dir=str2num(y.gpib);

%%clear
aux=instrfind('type','gpib','Status','close','Boardindex',gpib_dir,'primaryaddress',DSA_Primary_Address);
for i=1:length(aux) delete(aux(i));end

%dsa=instrfind('Status','open');%ojo! puede haber otros devices abiertos!
dsa=instrfind('type','gpib','Status','open','primaryaddress',DSA_Primary_Address);
if isempty(dsa)    
    dsa=gpib('ni',gpib_dir,DSA_Primary_Address);%dir:1 puede cambiar
    fopen(dsa); %cerrar al final.
end
%instrfind; %muestra los instrumentos y su estado.

%fprintf(dsa,'ID?');
%device=fscanf(dsa)%devuelve HP3562A. Permite comprobar si estamos leyendo el 
device=query(dsa,'ID?');%esta instruccion es más directa.
if ~strcmpi('HP3562A',device(1:end-2)), return;end %dispositivo correcto?