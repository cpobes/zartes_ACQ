%%%Script Read IVC Gauge
%%%Definimos los valores en la variable IVC_values y los salvamos en el
%%%fichero Pivc. El IVC está en el COM5
WS_variables=who;
if(~sum(~cellfun('isempty',strfind(WS_variables,'IVC_values')))) IVC_values=[];end
%if isempty(instrfind('Port','COM5')), ivc=serial('com5');end %%%COM 5 en
%PC viejo. COM 6 en PC nuevo
if isempty(instrfind('Port','COM6')), ivc=serial('com6');end
if strcmp(ivc.status,'closed') fopen(ivc);end
str=sprintf('%s\r\n','COM,1');
query(ivc,str);
out=fgets(ivc);
out2=regexp(out,'(?<presion>\d.\d*E(-?\+?)\d*),','names')
if isempty(out2) save('Pivc','IVC_values');return;end
IVC_Preassure=str2double(out2.presion);
IVC_values(end+1,:)=[now IVC_Preassure];
%figure(2)
%plot(IVC_values(:,1),IVC_values(:,2)*1e-1,'o-'),dateaxis('X',15);grid on
xlabel('hora','fontsize',12,'fontweight','bold')
ylabel('IVC Preassure (bar)','fontsize',12,'fontweight','bold')
title('Presión de la IVC','fontsize',12,'fontweight','bold')
set(gca,'fontsize',12,'fontweight','bold');
h=get(gca,'children');set(h,'linewidth',3,'marker','.','markersize',20)
IVCfile=strcat(datadir,'\Pivc')
save(IVCfile,'IVC_values');
fclose(ivc);