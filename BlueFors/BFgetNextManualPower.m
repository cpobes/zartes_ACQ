function newdata=BFgetNextManualPower(last,pid)
%%% funcion para devolver el valor de potencia en t+1 a partir de los datos
%%% en 't'.
Tlast=last.T;
Elast=last.E;
DElast=last.DE;
Wlast=last.W;
t0last=last.timestamp;
Tset=last.Tset;
P=pid.P;
I=pid.I;
D=pid.D;
[T,info]=BFreadMCTemp();
t0new=info.timestamp;
DT=t0new-t0last;
Enew=Tset-T;
DEnew=(Enew-Elast)/DT;
Wnew=Wlast+P*(Enew-Elast)+I*Enew*DT+D*(DEnew-DElast);
newdata.W=Wnew;
newdata.E=Enew;
newdata.DE=DEnew;
newdata.T=T;
newdata.Tset=Tset;
newdata.timestamp=t0new;