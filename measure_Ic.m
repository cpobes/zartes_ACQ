function IV=measure_Ic(Temp,Ivalues,varargin)
%%%Medidas de Icritica pasando Ivalues en uA.
%%%V20oct17 incorporo funciones _CH.
if nargin==3
    opt=varargin{1};%%%option for plot
else
    opt='.-';
end

mag=mag_init();
nCH=2;%%%Canal de la fuente externa a usar.
multi=multi_init();

if(abs(Ivalues(end)))>500
    mag_ConnectLNCS(mag);
    mag_setLNCSImag(mag,0);
end

Rf=mag_readRf_FLL_CH(mag,nCH);
mag_setRf_FLL_CH(mag,7e2,nCH);%700
Rfnew=mag_readRf_FLL_CH(mag,nCH);

%%%Reseteamos el lazo.
mag_setAMP_CH(mag,nCH);
mag_setFLL_CH(mag,nCH);

boolplot=1;

if(abs(Ivalues(end)))>500
    vout1=0;
    for i=1:length(Ivalues)
        Ivalues(i)
        mag_setLNCSImag(mag,Ivalues(i));
        %mag_setImag(mag,Ivalues(i));
        pause(1)%0.5
        vout2=multi_read(multi);
        IV.ic(i)=mag_readLNCSImag(mag);
        %IV.ic(i)=mag_readImag(mag);
        IV.vc(i)=vout2;
        %if abs(vout2)-abs(vout1)<0, break;end
        vout1=vout2;
        
            x(i)=IV.ic(i)*1e-6;
            y(i)=vout2;
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
else
    slope=1;
    mag_setImag_CH(mag,Ivalues(1),nCH);
    IV.ic(1)=mag_readImag_CH(mag,nCH)
    pause(1)
    vout1=multi_read(multi)
    IV.vc(1)=vout1;    
            x(1)=IV.ic(1)*1e-6;
            y(1)=vout1;
            if (boolplot)
                figure(1)
                h=plot(x,y,'o-k','linewidth',3);hold on;grid on
                %plot(Ireal*1e-6,Vdc,'ok','linewidth',3);hold on;grid on
                %linkdata(1);
                set(h,'xdatasource','x','ydatasource','y','linestyle','-');
            end
    for i=2:length(Ivalues)
        
        Ivalues(i)
        mag_setImag_CH(mag,Ivalues(i),nCH);
        pause(0.5)%0.5
        vout2=multi_read(multi);
        IV.ic(i)=mag_readImag_CH(mag,nCH);
        IV.vc(i)=vout2
        x(i)=IV.ic(i)*1e-6;
        y(i)=vout2;
        if (boolplot),refreshdata(1,'caller');end
        %if (abs(vout2*1e6)-abs(vout1*1e6))<0, break;end
        %vout2,vout1
        Ivalues(i),Ivalues(i-1)
        slope=(vout2-vout1)/((Ivalues(i)-Ivalues(i-1))*1e-6)/Rfnew
        
        if slope<1,break;end
        vout1=vout2;
    end
    mag_setImag_CH(mag,0,nCH);
end

mag_setRf_FLL_CH(mag,Rf,nCH);

if(abs(Ivalues(end)))>500
    mag_setLNCSImag(mag,0);
    mag_DisconnectLNCS(mag);
end

data(:,2)=IV.ic;
data(:,4)=IV.vc-IV.vc(1);
if Ivalues(end)>0, pol='p';else pol='n';end
file=strcat('Ic_',Temp,'_',pol,'_matlab.txt');
save(file,'data','-ascii');
figure(3)
%plot(abs(IV.ic),abs(IV.vc),opt)
plot(data(:,2),data(:,4),opt)

%%%cerrar ficheros
fclose(mag)
fclose(multi)
%instrreset