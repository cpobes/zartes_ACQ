figure('windowstyle','docked')
T=[];x=[];
plot(x,T);
datetick('x',13)
for i=1:1000
    T=[T LKS_readKelvinFromInput(lks,'B')];
    x=[x now];
    set(gco,'xdata',x)
    set(gco,'ydata',T)
    plot(x,T,'.-');grid on
    datetick('x',13)
    refreshdata
    drawnow
    pause(0.25)   
    disp(i)
end