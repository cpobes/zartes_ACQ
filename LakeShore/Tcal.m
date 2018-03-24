function T=Tcal(R)
%%%Funcion de calibracion del Termometro L0.
%%% !!! HAY QUE PASAR R en KOhm.
%%% A=[a0 a1 a2 a3]

R0=2.210;
A=[-0.6878755 1.1039783 0.0556154 -0.0103092];

% for i=0:3
%     S(i+1,:)=A(i+1)*log(R-R0).^i;
% end
%LNT=sum(S,1);

LNT=A(1)+A(2)*log(R-R0)+A(3)*log(R-R0).^2+A(4)*log(R-R0).^3;

T=exp(-LNT);