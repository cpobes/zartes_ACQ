function newdata=BFgetNextManualPower(last,pid)
%%% funcion para devolver el valor de potencia en t+1 a partir de los datos
%%% en 't'.
if nargin==0%para la primera llamada se llama sin argumentos
    [T,info]=BFreadMCTemp();
    Hconfig=BFgetHeaterConfig();
    newdata.T=T;
    newdata.Tset=Hconfig.setpoint;
    newdata.W=Hconfig.power;%%%OJO: si no esta en modo manual va a devolver cero.
    newdata.E=newdata.Tset-T;
    newdata.DE=0;
    newdata.timestamp=info.timestamp;
else
    Tlast=last.T;
    Elast=last.E;
    DElast=last.DE;
    Wlast=last.W;
    t0last=last.timestamp;
    Tset=last.Tset;
    P=pid.proportional;%P;%P
    I=pid.integral;%I;%I
    D=pid.derivative;%D;%D
    [T,info]=BFreadMCTemp();
    t0new=info.timestamp;
    DT=t0new-t0last;
    Enew=Tset-T;
    if DT==0
        DEnew=DElast;
    else
        DEnew=(Enew-Elast)/DT;
    end
    Wnew=Wlast+P*((Enew-Elast)+Enew*DT/I+D*(DEnew-DElast));
    newdata.W=Wnew;
    newdata.E=Enew;
    newdata.DE=DEnew;
    newdata.T=T;
    newdata.Tset=Tset;
    newdata.timestamp=t0new;
end