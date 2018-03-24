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
mag_setRf_FLL_CH(mag,3e3,sourceCH);
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

for i=1:length(Ibvalues)
    strcat('Ibias:',num2str(Ibvalues(i)))
    if slope>3000 state=1;end %%% state=1 -> estado superconductor. Ojo, la slope=3000 es para Rf=3K.
    if state && mod(Ibvalues(i),10), continue;end
    %mag_setLNCSImag(mag,Ibvalues(i));%%%Fuente LNCS en Ch3
    mag_setImag_CH(mag,Ibvalues(i),sourceCH);%%%Fuente en Ch1
    %if (Ibvalues(i)<125 & Ibvalues(i)>114),pause(0.5);else pause(2);end%%%%PSL
    if i==1, pause(2);end
    pause(1.)
    
    for i_av=1:averages
        Vdc_array(i_av)=multi_read(multi);
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
        slope=(data(i,4)-data(i-1,4))/((data(i,2)-data(i-1,2))*1e-6)
    end
    if (boolplot)
        figure(1)
        if i==1
            h=plot(x,y,'o-k','linewidth',3);hold on;grid on
            %plot(Ireal*1e-6,Vdc,'ok','linewidth',3);hold on;grid on
            %linkdata(1);
            set(h,'xdatasource','x','ydatasource','y','linestyle','-');
        end
        refreshdata(1,'caller');
    end
end

IV=corregir1rama(data);
% IV.ibias=data(:,2)*1e-6;
% IV.vout=data(:,4)-data(end,4);
IV.Tbath= sscanf(Temp,'%dmK')*1e-3;
%plot(signo*IV.ibias,signo*IV.vout,'.-');
figure(2)
plot(IV.ibias,IV.vout,'.-');

%%%guardar datos
Rf=mag_readRf_FLL_CH(mag,sourceCH)/1000;
file=strcat(Temp,'_Rf',num2str(Rf),'K_',dire,'_',pol,'_matlab.txt');
save(file,'data','-ascii');

%%%cerrar ficheros
fclose(mag);delete(mag);
fclose(multi);delete(multi);
%instrreset