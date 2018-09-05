function IV=acquireIVs(Temp,Ibvalues)
%%%Funcion para adquirir IVs con matlab leyendo el HP3458A y con step de
%%%corriente variable. Ojo, pasar Ibias values en uA.
%%%Pasar Temp como 'xxmK' string
%%%Version 17Oct17. Paso funciones CH.
%%%Version 3Nov17. Incorporo refreshdata para pintar a la vez que adquiere.

%%%%%Check Dir
f=dir;
q=regexp({f.name},'\d*.?\d*mK','match');
%%%Esto comprueba que no haya ficheros en el directorio con esa temperatura
%%%para no machacarlos.
%%%Pero da error cuando va a pillar el 'n'
% for i=1:length(q)
%     if(strcmp(q{i},Temp)) error('Ojo:Ya hay un fichero con esa Temp');end
% end

%%%QUE FUENTE SE USA
sourceCH=2;

boolplot=1;%%%si queremos o no pintar la curva.

mag=mag_init();
multi=multi_init();
Rf=1e4;
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
mag_setAMP_CH(mag,sourceCH);
mag_setFLL_CH(mag,sourceCH);

slope=0;state=0;jj=1;
averages=1;

% mag_ConnectLNCS(mag);%%%%
%     mag_setLNCSImag(mag,signo*0.5e3);
%     mag_setImag_CH(mag,0,sourceCH);%%%Fuente en Ch1
%%
slopeTHR=1; %%% pendiente umbral normalizada. La pendiente superconductora dividida por Rf es >1.
psl=0;%%%%condición si se mide PSL pq al hacer el step tan pequeño, puede simularse salto superconductor sin serlo.
for i=1:length(Ibvalues)
    strcat('Ibias:',num2str(Ibvalues(i)))
    if slope/Rf>slopeTHR && slope<Inf && ~psl
        state=1;
    end %%% state=1 -> estado superconductor. Ojo, la slope=3000 es para Rf=3K.
    if state && mod(Ibvalues(i),10), continue;end  %%%mod(,10)
    %mag_setLNCSImag(mag,Ibvalues(i));%%%Fuente LNCS en Ch3
    mag_setImag_CH(mag,Ibvalues(i),sourceCH);%%%Fuente en Ch1
    %if (Ibvalues(i)<125 & Ibvalues(i)>114),pause(0.5);else pause(2);end%%%%PSL
    if i==1, pause(2); end
    pause(.5)
    
    for i_av=1:averages
        aux=multi_read(multi);
        %size(aux)
        std(aux)
%        if ~isempty(aux) && mean(aux)<1e5
            Vdc_array(i_av)=mode(aux);%%%a veces multi_read devuelve un array con varios valores y la asignación a v(i) da error.
%         else
%             aux=multi_read(multi);
%             Vdc_array(i_av)=mode(aux);
%         end
        %Vdc_array(i_av)=multi_read(multi);
    end
    Vdc=mean(Vdc_array);
    %Ireal=mag_readLNCSImag(mag);
    Ireal=mag_readImag_CH(mag,sourceCH);
    
    %%%Vout=mag_readVout(mag);
    data(jj,1)=now;
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bloque para automatizar la resolución de las Ibvalues

% Res_Orig = round(mean(diff(Ibvalues)));
% Res = Res_Orig;
% slope_curr = 0;
% Ibval = Ibvalues(1);
% jj = 1;
% while abs(Ibval(jj)) > 5 
%     
%     strcat('Ibias:',num2str(Ibval(jj)))
%     if slope_curr>3000 state=1;end %%% state=1 -> estado superconductor. Ojo, la slope=3000 es para Rf=3K.
% %     if state && mod(Ibval(jj),5), continue;end  %%%mod(,10)
%     mag_setImag_CH(mag,Ibval(jj),sourceCH);%%%Fuente en Ch1
%     if jj==1, pause(2); end
%     
%     for i_av=1:averages
%         aux=multi_read(multi);
%         size(aux)
%         Vdc_array(i_av)=mean(aux);        
%     end
%     Vdc=mean(Vdc_array);    
%     Ireal=mag_readImag_CH(mag,sourceCH);
%     
%     
%     data(jj,1)=now;
%     data(jj,2)=Ireal;%*1e-6;
%     data(jj,3)=0;%%%Vout
%     data(jj,4)=Vdc;
%     x(jj)=Ireal*1e-6;
%     y(jj)=Vdc;
%     
%     if jj < 12 && jj > 1 && ~state % Por lo menos tendremos 5 valores para poder promediar              
%         slope(jj-1) = (data(jj,4)-data(jj-1,4))/((data(jj,2)-data(jj-1,2)));
%          Res = Res_Orig;
%     elseif jj >= 12
%         slope_curr = (data(jj,4)-data(jj-1,4))/((data(jj,2)-data(jj-1,2)));        
%         if slope_curr > mean(slope)+std(slope) || slope_curr < mean(slope)-std(slope)
%             Res = Res_Orig*0.02;
%         else
%             Res = Res_Orig;
%         end                   
%     end
%     if Res ~= Res_Orig % Miramos ahora cuando sucede el salto, cuando lo hay.
%         if data(jj-1,4)
%             
%         end
%     end
%     jj=jj+1;
%     Ibval(jj) = Ibval(jj-1)+Res;
% end

%% Bloque para automatizar la busqueda de IC criticas basadas en el slope

% % Presenta problemas de Histeresis aunque he intentado volver al punto de
% % estado normal siguiendo todos los pasos.  
% 
% % Importante poner el TES en estado normal para evitar la histeresis
% if ~Put_TES_toNormal_State_CH(mag,signo,sourceCH)
%     %instrreset;
%     error('El TES no se ha podido poner en estado normal');
% end
% 
% 
% % Rectificamos el array de valores de las diferencias de slope y los normalizamos.
% % Recordar que slope empieza en el segundo valor de Ibias. 
% % Recordar que las diferencias de slope también reduciran el número de
% % elementos del nuevo array. 
% 
% % Imponemos un criterio de desviación del 10% sobre la primera recta para
% % buscar la zona donde aplicar un barrido más fino.
% 
% tolerancia = 0.05;  % Este parametro se debería cambiar con la temperatura.
% 
% % El primer punto debe de ser de nuevo 500mA o -500mA para asegurar que no
% % haya efecto de histeresis.
% mag_setRf_FLL_CH(mag,1e4,sourceCH);%3e3
% %%%Reseteamos el lazo.
% mag_setAMP_CH(mag,sourceCH);
% mag_setFLL_CH(mag,sourceCH);
% 
% 
% SlopeRectNorm = abs(diff(slope))/max(abs(diff(slope)));
% % figure,plot(SlopeRectNorm)
% indx = find(SlopeRectNorm >= tolerancia); 
% while isempty(indx) % El cambio es menor que la tolerancia impuesta
%     tolerancia = tolerancia*0.8;
%     indx = find(SlopeRectNorm >= tolerancia); 
% end
% Ibvalues_critico(1) = Ibvalues(indx(1)-5); % será nuestro primer punto al que le hemos retrasado el comienzo (5 muestras) 
% 
% % Aumentamos la resolución en un 80%
% Res = round(mean(diff(Ibvalues)));
% Res = Res*0.2;
% 
% % Cuando el material esta en estado superconductor no es necesario
% % continuar con una resolución tan baja.  Pero no en todos los casos
% % aparece una recta tan bien definida.
% 
% % Caso 1. Tenemos un rango de Ibvalues en estado superconductor que
% % producen una recta.
% 
% % Después de la transición la SlopeRectNorm debería de no superar la
% % tolerancia. Los valores de indx empiezan siendo consecutivos marcando la
% % transición. El siguiente valor de SlopeRectNorm que esté por debajo de la
% % tolerancia será el que marque la nueva zona superconductora y por lo
% % tanto tendrá otra resolución.
% 
% indx_FinTrans = indx(diff(indx) > 1)+1;  % Se añade el +1 para corregir el diff.
% 
% if ~isempty(indx_FinTrans)
%     Ibvalues_critico = [Ibvalues(1:2:6) Ibvalues_critico(1):Res:Ibvalues(indx_FinTrans)];
% else % Caso 2. El rango de Ibvalues en estado superconductor no consiguen que se    
%      % producta una recta sino más bien un aumento de la pendiente. Por lo
%      % que una primera aproximación sería mantener esta alta resolución
%      % hasta el final del rango
%      Ibvalues_critico = [Ibvalues(1:2:6) Ibvalues_critico(1):Res:0];
% end
% for i = 1:length(Ibvalues_critico)
%     mag_setImag_CH(mag,Ibvalues_critico(i),sourceCH);
%     if i==1, pause(2); end
%     strcat('Ibias:',num2str(Ibvalues_critico(i)))    
%     for i_av=1:averages
%         aux=multi_read(multi);
%         Vdc_array(i_av)=mean(aux);%%%a veces multi_read devuelve un array con varios valores y la asignación a v(i) da error.
%         %Vdc_array(i_av)=multi_read(multi);
%     end
%     Vdc=mean(Vdc_array);
%     %Ireal=mag_readLNCSImag(mag);
%     Ireal=mag_readImag_CH(mag,sourceCH);
%     
%     %%%Vout=mag_readVout(mag);
%     data(jj,1)=now;
%     data(jj,2)=Ireal;%*1e-6;
%     data(jj,3)=0;%%%Vout
%     data(jj,4)=Vdc;
%     x(jj)=Ireal*1e-6;
%     y(jj)=Vdc;
%     jj=jj+1;
% end
% 
% % Reordenamos los valores del la matriz data
% [val, indx_data] = sort(data(:,2),'descend');
% data(:,1) = data(indx_data,1);
% data(:,2) = val;
% data(:,3) = data(indx_data,3);
% data(:,4) = data(indx_data,4);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% mag_setLNCSImag(mag,0);%%%%%
% mag_DisconnectLNCS(mag);%%%%%

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