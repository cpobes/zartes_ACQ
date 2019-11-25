function LKS_SetCurvePoints(lks,CurveNum,Rrange,varargin)
%%%Funci�n para cargar una curva de calibraci�n en una curva de usuario
%%%dada. P143 manual.

if nargin==3
    Trange=Tcal(Rrange/1e3);%%% Tcal tiene que tener cargada la calibraci�n adecuada.
                    %%%%%%%%Se pasan los valores en KOhm
else
    Trange=varargin{1};
end

for i=1:length(Rrange)
    %str=strcat('CRVPT ',[' ' num2str(CurveNum)],num2str(i),num2str(Rrange(i)),num2str(Trange(i)),'\n')
    str=strcat('CRVPT ',[' ' num2str(CurveNum)], ',' ,num2str(i), ',', num2str(Rrange(i)), ',', num2str(Trange(i)),'\n')
    query(lks,str);
end