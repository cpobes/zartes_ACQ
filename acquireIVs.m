function IV=acquireIVs(Temp,Ibvalues, varargin)
%%%Funcion para adquirir IVs con matlab leyendo el HP3458A y con step de
%%%corriente variable. Ojo, pasar Ibias values en uA.
%%%Pasar Temp como 'xxmK' string
%%%Version 17Oct17. Paso funciones CH.
%%%Version 3Nov17. Incorporo refreshdata para pintar a la vez que adquiere.
%%%Version 06Feb19. Incorporo condición para usar LNCS o fuente de CH sin
%%%tener que comentar/descomentar código. Añado varargin para pasar como
%%%una estructura nuevos parámetros de configuración. (ojo, hay que pasar
%%%todos aunque se cambie sólo 1).

%%%%%Check Dir
f=dir;
q=regexp({f.name},'\d*.?\d*mK','match');
%%%Esto comprueba que no haya ficheros en el directorio con esa temperatura
%%%para no machacarlos.
%%%Pero da error cuando va a pillar el 'n'
% for i=1:length(q)
%     if(strcmp(q{i},Temp)) error('Ojo:Ya hay un fichero con esa Temp');end
% end
format long
if nargin==2
    %%%QUE FUENTE SE USA
    sourceCH=2;
    boolplot=1;%%%si queremos o no pintar la curva.
    Rf=3e3;%%%Rf
    averages=5;
    %%%%Fuente a usar: LNCS. Normal
    sourceType='Normal';%%% o 'Normal'.
    softpolarity=1;
    useFanInOut=1;
    OutputDir='.\';
    Ibobina=0;
elseif nargin==3
    opt=varargin{1};%%%%Pasar las opciones en una estructura!
    sourceCH=opt.sourceCH;
    boolplot=opt.boolplot;
    Rf=opt.Rf;
    sourceType=opt.sourceType;
    averages=opt.averages;
    if isfield(opt,'softpolarity')
        softpolarity=opt.softpolarity;
    else
        softpolarity=1;
    end
    if isfield(opt,'useFanInOut')
        useFanInOut=opt.useFanInOut;
    else
        useFanInOut=1;
    end
    if isfield(opt,'OutputDir')
        OutputDir=opt.OutputDir;
    else
        OutputDir='.';%local Dir.
    end
    if isfield(opt,'Ibobina')
        Ibobina=opt.Ibobina;
    else
        Ibobina=0;
    end
    %k220=opt.k220;%%%
end

%%%use fan in fan out
%%%%
%useFanInOut=1;%%%Abril 2024
if useFanInOut
    fan=fanout_init();
    switch sourceCH
        case 1
            CH='b';
        case 2
            CH='B';
    end
    fanout_set(fan,CH);
    fclose(fan);
end

mag=mag_init();
multi=multi_init(0);%
mag_setLNCSImag(mag,Ibobina);
mag_setRf_FLL_CH(mag,Rf,sourceCH);%3e3
mag_LoopResetCH(mag,sourceCH);%asegurar FLL mode.
%%%Ponemos el máximo de corriente 
signo=sign(Ibvalues(1));

if ~Put_TES_toNormal_State_CH(mag,Ibvalues(1),sourceCH) && abs(Ibvalues(1))>abs(Ibvalues(2))%%%,k220. signo
    %instrreset;
    %error('El TES no se ha podido poner en estado normal');
    warning('El TES no se ha podido poner en estado normal');
end

if Ibvalues(1)>0
    %mag_setImag(mag,500);
    pol='p';
    dire='down';
elseif Ibvalues(1)<0
    %mag_setImag(mag,-500);
    pol='n';
    dire='down';
else
    dire='up';
    if Ibvalues(end)>0 pol='p';else pol='n';end
end

pause(2)
mag_LoopResetCH(mag,sourceCH);

if isfield(opt,'IV_THR')
    IV_THR=opt.IV_THR;
else
    IV_THR=5;%umbral en Vout para el autoreseteado.
end
mag_setAutoResetON_CH(mag,IV_THR,sourceCH);%Dejamos rango para IV pero evitamos salto a 10V.
%Y si esta puesto a 1V por Zs,pulsos, lo reseteamos.
pause(2)

rango=1e3;
%%%Si la salida es estable, la fluctación en la
%%%salida es menor de 1mV.
rangoindx=1;
rangoTHR=5e-3;
Nmonitor=10;%default=100
while rango>rangoTHR%2e-3%5e-4
    rango=multi_monitor(multi,Nmonitor);
    %'monitoring...'
    disp(sprintf('monitoring Vout... Range=%s',num2str(rango)));
    rangoindx=rangoindx+1;
    if rangoindx>25 break;end
end
slope=0;state=0;jj=1;

if strcmpi(sourceType,'LNCS')
 mag_ConnectLNCS(mag);%%%%
     mag_setLNCSImag(mag,signo*0.5e3);
     mag_setImag_CH(mag,0,sourceCH);%%%Fuente en Ch1
end
%%%

slopeTHR=1; %%% pendiente umbral normalizada. La pendiente superconductora dividida por Rf es >1.
psl=0;%%%%condición si se mide PSL pq al hacer el step tan pequeño, puede simularse salto superconductor sin serlo.
verbose=1;
t0start=now;
for i=1:length(Ibvalues)
    if verbose disp(strcat('Ibias:',num2str(Ibvalues(i)))); end
    if slope/Rf>slopeTHR && slope<Inf && ~psl
        state=1;
        disp('S state detected');
    end %%% state=1 -> estado superconductor. Ojo, la slope=3000 es para Rf=3K.
    %%%%Control de estado superconductor para cambiar Step.
    if state && mod(Ibvalues(i),5) && abs(Ibvalues(i))>10,
        disp('Skipped Ibias');
        continue;
    end  %%%mod(,10)
    if state && abs(Ibvalues(i))<10 && round(abs(Ibvalues(i)))~=abs(Ibvalues(i)), continue;end%si step es muy fino pasamos a step entero.
    
    if strcmpi(sourceType,'LNCS')
        mag_setLNCSImag(mag,Ibvalues(i));%%%Fuente LNCS en Ch3
    else
        mag_setImag_CH(mag,Ibvalues(i),sourceCH);%%%Fuente en Ch1
    end
    %if (Ibvalues(i)<125 & Ibvalues(i)>114),pause(0.5);else pause(2);end%%%%PSL
    %if i==1, pause(2); end
    
    %pause(1.5)
    
    for i_av=1:averages
        aux=multi_read(multi);
        %size(aux)
        %std(aux)
%        if ~isempty(aux) && mean(aux)<1e5
            Vdc_array(i_av)=mode(aux);%%%a veces multi_read devuelve un array con varios valores y la asignación a v(i) da error.
%         else
%             aux=multi_read(multi);
%             Vdc_array(i_av)=mode(aux);
%         end
        %Vdc_array(i_av)=multi_read(multi);
    end
    Vdc=mean(Vdc_array);
    if abs(Vdc)>IV_THR %Forzamos a empezar con un offset no muy alto. 
        mag_LoopResetCH(mag,sourceCH);

        %%%cuando salta el squid, hay una deriva larguisima en el Vout.
        rango=1e3;
        rangoindx=1;
        while rango>rangoTHR
            rango=multi_monitor(multi,Nmonitor);
            disp(sprintf('monitoring Vout at Ibias %suA. Range=%s',num2str(Ibvalues(i)),num2str(rango)));
            rangoindx=rangoindx+1;
            if rangoindx>25 break;end
        end
        for i_av=1:averages
            aux=multi_read(multi);
            Vdc_array(i_av)=mode(aux);
        end
    Vdc=mean(Vdc_array);
    end
    if strcmpi(sourceType,'LNCS')
        Ireal=mag_readLNCSImag(mag);
    else
        Ireal=mag_readImag_CH(mag,sourceCH);
    end
    
    %%%Vout=mag_readVout(mag);
%     t0=datetime('now');
%     t0.Format='dd-MMM-yyyy HH:mm:ss.SSSSSSSSS';
    t0=(now-t0start)*1e5;%%%t0 en segundos desde inicio del loop. %%%t0_start=737834.48
    data(jj,1)=t0;
    data(jj,2)=Ireal;%*1e-6;
    data(jj,3)=0;%%%Vout
    data(jj,4)=softpolarity*Vdc;
    x(jj)=data(jj,2)*1e-6;
    y(jj)=data(jj,4);
    jj=jj+1;
    if i>1 && ~state
        slope= (data(i,4)-data(i-1,4))/((data(i,2)-data(i-1,2))*1e-6);
    end
    if (boolplot)
            auxhandle_1=findobj('name','IV_raw');
            if isempty(auxhandle_1) figure('name','IV_raw'); auxhandle_1=findobj('name','IV_raw'); else figure(auxhandle_1);end
        if i==1
            figure(auxhandle_1)
            hold off
            plot(x,y,'o-k','linewidth',3);hold on;grid on
            %plot(Ireal*1e-6,Vdc,'ok','linewidth',3);hold on;grid on
            %linkdata(1);
            %set(h,'xdatasource','x','ydatasource','y','linestyle','-');
            %set(get(gca,'children'),'Xdata',x,'Ydata',y);
        end
        set(get(gca,'children'),'Xdata',x,'Ydata',y);
        drawnow
        %refreshdata(auxhandle_1,'caller');
    end
end

if strcmpi(sourceType,'LNCS')
    mag_setLNCSImag(mag,0);%%%%%
    mag_DisconnectLNCS(mag);%%%%%
else
    mag_setImag_CH(mag,0,sourceCH);%ponemos la fuente a 0.(a veces medimos más alla de cero).
end

mag_setAutoResetON_CH(mag,1,sourceCH);%refijamos el autoreset a 1V
mag_setAMP_CH(mag,1);
mag_setAMP_CH(mag,2);
%%%Deshabilitamos el modo FLL para evitar
%%%calentar el sistema si salta la salida a 10V.

IV=corregir1rama(data);
% IV.ibias=data(:,2)*1e-6;
% IV.vout=data(:,4)-data(end,4);
IV.Tbath= sscanf(Temp,'%dmK')*1e-3;
%plot(signo*IV.ibias,signo*IV.vout,'.-');

auxhandle_2=findobj('name','IVs_corregidas');
if isempty(auxhandle_2) figure('name','IVs_corregidas'); else figure(auxhandle_2);end
hold on;grid on;
plot(IV.ibias,IV.vout,'.-');

%%%guardar datos
Rf=mag_readRf_FLL_CH(mag,sourceCH)/1000;
file=strcat(Temp,'_Rf',num2str(Rf),'K_',dire,'_',pol,'_matlab.txt');
if ~exist(OutputDir,'dir')
    mkdir(OutputDir);
end
outfile=strcat(OutputDir,'\',file);%%%sirve tanto '.\' como '.\\'.
save(outfile,'data','-ascii');

%%%cerrar ficheros
fclose(mag);delete(mag);
fclose(multi);delete(multi);
%instrreset