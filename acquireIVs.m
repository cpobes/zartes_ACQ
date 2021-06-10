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
    sourceType='LNCS';%%% o 'Normal'.
elseif nargin==3
    opt=varargin{1};%%%%Pasar las opciones en una estructura!
    sourceCH=opt.sourceCH;
    boolplot=opt.boolplot;
    Rf=opt.Rf;
    sourceType=opt.sourceType;
    averages=opt.averages;
end

mag=mag_init();
multi=multi_init(0);%

mag_setRf_FLL_CH(mag,Rf,sourceCH);%3e3
%%%Ponemos el máximo de corriente 
signo=sign(Ibvalues(1));

if ~Put_TES_toNormal_State_CH(mag,signo,sourceCH)
    %instrreset;
    error('El TES no se ha podido poner en estado normal');
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

% 'Desactiva la fuente externa si está puesta'
% pause(10)
% 'Measure Start'

%%%Reseteamos el lazo.
% mag_setAMP_CH(mag,sourceCH);
% mag_setFLL_CH(mag,sourceCH);
pause(2)
mag_LoopResetCH(mag,sourceCH);
pause(2)

slope=0;state=0;jj=1;

if strcmpi(sourceType,'LNCS')
 mag_ConnectLNCS(mag);%%%%
     mag_setLNCSImag(mag,signo*0.5e3);
     mag_setImag_CH(mag,0,sourceCH);%%%Fuente en Ch1
end
%%%

slopeTHR=1; %%% pendiente umbral normalizada. La pendiente superconductora dividida por Rf es >1.
psl=1;%%%%condición si se mide PSL pq al hacer el step tan pequeño, puede simularse salto superconductor sin serlo.
verbose=0;
t0start=now;
for i=1:length(Ibvalues)
    if verbose strcat('Ibias:',num2str(Ibvalues(i))),end
    if slope/Rf>slopeTHR && slope<Inf && ~psl
        state=1;
    end %%% state=1 -> estado superconductor. Ojo, la slope=3000 es para Rf=3K.
    
    %%%%Control de estado superconductor para cambiar Step.
    if state && mod(Ibvalues(i),10) && abs(Ibvalues(i))>10, continue;end  %%%mod(,10)
    
    if strcmpi(sourceType,'LNCS')
        mag_setLNCSImag(mag,Ibvalues(i));%%%Fuente LNCS en Ch3
    else
        mag_setImag_CH(mag,Ibvalues(i),sourceCH);%%%Fuente en Ch1
    end
    %if (Ibvalues(i)<125 & Ibvalues(i)>114),pause(0.5);else pause(2);end%%%%PSL
    if i==1, pause(2); end
    
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
    data(jj,4)=Vdc;
    x(jj)=Ireal*1e-6;
    y(jj)=Vdc;
    jj=jj+1;
    if i>1 && ~state
        slope= (data(i,4)-data(i-1,4))/((data(i,2)-data(i-1,2))*1e-6);
    end
    if (boolplot)
            auxhandle_1=findobj('name','IV_raw');
            if isempty(auxhandle_1) figure('name','IV_raw'); auxhandle_1=findobj('name','IV_raw'); else figure(auxhandle_1);end
        if i==1
            h=plot(x,y,'o-k','linewidth',3);hold on;grid on
            %plot(Ireal*1e-6,Vdc,'ok','linewidth',3);hold on;grid on
            %linkdata(1);
            set(h,'xdatasource','x','ydatasource','y','linestyle','-');
        end
        
        refreshdata(auxhandle_1,'caller');
    end
end

if strcmpi(sourceType,'LNCS')
    mag_setLNCSImag(mag,0);%%%%%
    mag_DisconnectLNCS(mag);%%%%%
end

IV=corregir1rama(data);
% IV.ibias=data(:,2)*1e-6;
% IV.vout=data(:,4)-data(end,4);
IV.Tbath= sscanf(Temp,'%dmK')*1e-3;
%plot(signo*IV.ibias,signo*IV.vout,'.-');

auxhandle_2=findobj('name','IVs_corregidas');
if isempty(auxhandle_2) figure('name','IVs_corregidas'); else figure(auxhandle_2);end
hold on;
plot(IV.ibias,IV.vout,'.-');

%%%guardar datos
Rf=mag_readRf_FLL_CH(mag,sourceCH)/1000;
file=strcat(Temp,'_Rf',num2str(Rf),'K_',dire,'_',pol,'_matlab.txt');
save(file,'data','-ascii');

%%%cerrar ficheros
fclose(mag);delete(mag);
fclose(multi);delete(multi);
%instrreset