function k220=k220_setVlimit(k220,varargin)
%%%Funci�n para cambiar el l�mite m�ximo de Voltaje de la fuente.
%%%Por defecto se pone a 50V si no se pasa segundo argumento.
%%% El l�mite se pasa como n�mero double en Voltios.
if nargin==1
    Vmax=50;
else
    Vmax=varargin{1};
end
    
str=strcat('V',num2str(Vmax),'X','\n');
query(k220,str);