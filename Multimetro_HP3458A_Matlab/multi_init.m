function multi=multi_init(varargin)
%Función para inicializar una sesión con el multimetro HP.
% 
if nargin == 0
    gpib_dir=0;
else
    gpib_dir=varargin{1};
end

%%%%%%%%%%%%Error instrfind!!!!!!!!!!!
%%clear
 aux=instrfind('type','gpib','Status','closed','Boardindex',gpib_dir,'primaryaddress',4);
 for i=1:length(aux) delete(aux(i));end

multi=instrfind('type','gpib','Status','open','primaryaddress',4);
if isempty(multi)    
    multi=gpib('ni',gpib_dir,4);%dir:1 puede cambiar
    fopen(multi); %cerrar al final.
end
%instrfind; %muestra los instrumentos y su estado.

%fprintf(dsa,'ID?');
%device=fscanf(dsa)%devuelve HP3562A. Permite comprobar si estamos leyendo el 
device=query(multi,'ID?');%esta instruccion es más directa.
%if ~strcmpi('HP3458A',device(1:end-2)), return;end %dispositivo
%correcto?Este comando fallaba pq ademas de devolver el código, devuelve también un
%array de valores de voltaje.
if ~strcmpi('HP3458A',device(1:7)), return;end %dispositivo correcto?

%%% Importante para poder saber si la conexión es buena.
% device(8:9) = char([13 10]);  % Al parecer estos dos caracteres conforman
% un salto de carro lo que vendría a ser un \n

%%%Configuración copiada del programa de test de LabView modulo hp3458a
%%%Config Vdc. Con la configuración por defecto daban error los programas
%%%de IV etc y tenia que ejecutar a mano el programa de LabView.

%command='RESET; END 1; FUNC DCV, 10; NPLC 5'; %%% NPLC 10 -> 1.  % Aquí el FUNC DCV, 10.3e  produce un error de syntaxis. -> .3e es el formato!aqui sobra.
command='RESET; END 1; NPLC 5';
query(multi,command);