function multi=multi_init(varargin)
%Funci�n para inicializar una sesi�n con el multimetro HP.
% 
Multi_Primary_Address=4;%leer from .json?
if nargin == 0
    gpib_dir=1;%%%antes default = 0.
else
    gpib_dir=varargin{1};
end

%%%%%%%%%%%%Error instrfind!!!!!!!!!!!
%%clear
 aux=instrfind('type','gpib','Status','closed','Boardindex',gpib_dir,'primaryaddress',Multi_Primary_Address);
 for i=1:length(aux) delete(aux(i));end

multi=instrfind('type','gpib','Status','open','primaryaddress',Multi_Primary_Address);
if isempty(multi)    
    multi=gpib('ni',gpib_dir,Multi_Primary_Address);%dir:1 puede cambiar
    fopen(multi); %cerrar al final.
    multi.EOSmode='read';
end
%instrfind; %muestra los instrumentos y su estado.

%fprintf(dsa,'ID?');
%device=fscanf(dsa)%devuelve HP3562A. Permite comprobar si estamos leyendo el 
device=query(multi,'ID?'); %esta instruccion es m�s directa.
%if ~strcmpi('HP3458A',device(1:end-2)), return;end %dispositivo
%correcto?Este comando fallaba pq ademas de devolver el c�digo, devuelve tambi�n un
%array de valores de voltaje.
x=strfind(device,'HP3458A');
if isempty(x)
%if ~strcmpi('HP3458A',device(1:7)) %Apr24 da error pq device sale vac�o
%aunq la comunicacion es buena.
    warning('Comprueba comunicacion con Multi');
end %dispositivo correcto?

%%% Importante para poder saber si la conexi�n es buena.
% device(8:9) = char([13 10]);  % Al parecer estos dos caracteres conforman
% un salto de carro lo que vendr�a a ser un \n

%%%Configuraci�n copiada del programa de test de LabView modulo hp3458a
%%%Config Vdc. Con la configuraci�n por defecto daban error los programas
%%%de IV etc y tenia que ejecutar a mano el programa de LabView.

%command='RESET; END 1; FUNC DCV, 10; NPLC 5'; %%% NPLC 10 -> 1.  % Aqu� el FUNC DCV, 10.3e  produce un error de syntaxis. -> .3e es el formato!aqui sobra.
command='RESET; END 1; NPLC 5';
query(multi,command);