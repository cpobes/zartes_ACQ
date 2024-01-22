function k220=k220_setVlimit(k220,varargin)
%%%Función para cambiar el límite máximo de Voltaje de la fuente.
%%%Por defecto se pone a 50V si no se pasa segundo argumento.
%%% El límite se pasa como número double en Voltios.
if nargin==1
    Vmax=50;
else
    Vmax=varargin{1};
end
    
str=strcat('V',num2str(Vmax),'X','\n');
query(k220,str);