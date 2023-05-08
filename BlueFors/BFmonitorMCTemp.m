function varargout=BFmonitorMCTemp(varargin)
%%%Intento de monitorizacion de Tbath.
%%%Salvo los valores de timestamp y Temp. Se podría leer el power,
%%%pero en modo PID, el heater_power es siempre cero. Como acceder al valor
%%%real de power?
Tmonitor=2400;%%%Max tiempo en 
if nargin==1
    Tset=varargin{1};
end
Ethr=30e-6;%%%error threshold en K
Sthr=15;%%%Slope threshold en uK/min
[T,msg]=BFreadMCTemp();
t0=msg.timestamp;
Temp(1)=T;
t=t0;
timestamp(1)=t-t0;
Tstd(1)=0;

boolplot=0;
if(boolplot)
auxhandle=findobj('name','BF_monitor');
if isempty(auxhandle) 
    auxhandle=figure('name','BF_monitor'); 
else figure(auxhandle);
end
plot(timestamp,Temp,'o-')
grid on;
set(gca,'fontsize',20);
xlabel('time(seg)');
ylabel('T(K)');
end%%%boolplot
icounter=1;
'Starting BF Temp monitoring'
while t-t0<Tmonitor
    fprintf(1,'%s','.');
    if ~mod(icounter,100) fprintf(1,'\n');end
    pause(1)
    [T,msg]=BFreadMCTemp();
    t=msg.timestamp;
    Temp(end+1)=T;
    timestamp(end+1)=t-t0;
    if ~mod(icounter,200) fprintf(1,'Elapsed Time(seg): %d\n', t-t0);end
    %Tstd(end+1)=std(Temp);
    if boolplot
        figure(auxhandle)
        child=get(gca,'children');
        set(child,'Xdata',timestamp,'Ydata',Temp);
        set(child,'marker','o');
    end
    icounter=icounter+1;
    %%%pendiente el ultimo minuto
    L=numel(Temp);
    if L<=12 continue;end
    m=polyfit(timestamp(end-12:end),Temp(end-12:end),1);
    if nargin==1 && abs(mean(Temp(end-12:end))-Tset)<Ethr && abs(m(1)*60/1e-6)<Sthr
        break;
    end
end
out.timestamp=timestamp(:);%%%los escribimos en columnas para convertir mejor a tabla.
out.Temp=Temp(:);
%out.Tstd=Tstd;
varargout{1}=out;