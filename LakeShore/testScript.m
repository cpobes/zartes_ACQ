figure('windowstyle','docked')
T_LK=[];x=[];
R=[];Tcal=[];
lksCurrent=[];
plot(x,Tcal);
datetick('x',13)
Capturas=1500;
for i=1:Capturas
    T_LK=[T_LK LKS_readKelvinFromInput(lks,'B')];
    raux=LKS_readSensorFromInput(lks,'B');
    R=[R raux];
    taux=interp1(logR,Tmc,log10(raux));
    Tcal=[Tcal taux];
    lksCurrent=[lksCurrent LKS_readHeaterCurrent(lks,2)];
    x=[x now];
    set(gco,'xdata',x)
    set(gco,'ydata',Tcal)
    plot(x,Tcal,'.-');grid on
    datetick('x',13)
    refreshdata
    drawnow
    pause(0.25)   
    disp(i)
end