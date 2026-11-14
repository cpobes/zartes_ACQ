figure('windowstyle','docked')
T_LK=[];x=[];
R=[];Tcal=[];
lksPower=[];
plot(x,Tcal);
datetick('x',13)
Capturas=1000;
for i=1:Capturas
    T_LK=[T_LK LKS_readKelvinFromInput(lks,'A')];%'B'
    %raux=LKS_readSensorFromInput(lks,'A');
    %R=[R raux];
    %taux=interp1(logR,Tmc,log10(raux));
    %Tcal=[Tcal taux];
    lksPower=[lksPower LKS_readHeaterPercentage(lks,0)];
    x=[x now];
    set(gco,'xdata',x)
    Tdata=T_LK;%Tcal
    set(gco,'ydata',Tdata)
    plot(x,Tdata,'.-');grid on
    
    refreshdata
    drawnow
    pause(0.5)   
    disp(i)
end