function Bscan(varargin)
%%%funcion para hacer el Bscan. Ojo, poner antes el TES en medio de la
%%%transicion y recordar apagar a mano al final la fuente.
%%%Recordar: Valores de corriente en uA.(Luego se convierten a A).
if nargin==0
    step=50;
    ini=-500;%Valores de corriente en uA.
    fin=500;
else
    data=varargin{1};
    step=data.step;
    ini=data.ini;%Valores de corriente en uA.
    fin=data.fin;
    if nargin==2 
        fnameStr=varargin{2}; 
    else
        fnameStr='';
    end
end
%B=[0:step:1000 1000:-step:0 0:-step:-500 -500:step:0]*1e-6;
B=[ini:step:fin fin:-step:ini];%*1e-6;%%en realidad es la corriente. No tenemos la calibracion exacta de esta bobina!
%clear V
%B=[0 100 0 200 0 300 0 400 0 500 0 -100 0 -200 0 -300 0 -400 0 -500 0]*1e-6; 
%B=[0 20 0 40 0 60 0 80 0 100 0 120 0 140 0 160 0 180 0 200 0 -20 0 -40 0 -60 0 -80 0 -100 0 -120 0 -140 0 -160 0 -180 0 -200 0]*1e-6; 
multi=multi_init(0);
%k220=k220_init(0);
mag=mag_init();
mag_ConnectLNCS(mag);%por si no esta conectada.
%mag_readLNCSImag(mag)%
'hello'
pause(1)
for i=1:length(B)
    B(i)
    %for ii=1:2 %%%Parece que tras un Start exitoso sí funciona el setI.
        %try
       %     k220_Start(k220);
        %catch
        %end
    %end
    %k220.HandshakeStatus
%k220_setI(k220,B(i));
mag_setLNCSImag(mag,B(i))
mag_readLNCSImag(mag)%
pause(1)
%B(i)
    V(i)=mean(multi_read(multi));
    if i==1
        auxhandle=findobj('name','Bscan');
        if isempty(auxhandle) figure('name','Bscan'); else figure(auxhandle);end
        hold on;grid on;
        h=plot(B(i),V(i),'o-','markerfacecolor','r');
    else
        xdata=B(1:i);%B tiene longitud fija pero V va creciendo.
        ydata=V;
        set(h,'XData',xdata,'YData',ydata');
        %plot(B([1:i]),V([1:i]),'o-','markerfacecolor','r');
    end
end
fname=strcat('BscanData',fnameStr);
save(fname,'B','V')
%k220_setI(k220,0);da error.pq?
%mag_setLNCSImag(mag,0);
%mag_DisconnectLNCS(mag)
