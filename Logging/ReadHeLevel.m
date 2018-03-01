%function ReadHeLevel(ilm,Level)
%%% read Level. El ILM está en el COM4.
%%%Definimos los valores en la variable 'Level' y los salvamos
%%% en el fichero HeLevel
WS_variables=who;
if(~sum(~cellfun('isempty',strfind(WS_variables,'Level')))) Level=[];end
if isempty(instrfind('Port','COM4')), ilm=serial('com4');end
if strcmp(ilm.status,'closed') fopen(ilm);end
if(~sum(~cellfun('isempty',strfind(WS_variables,'boolplot')))) boolplot=1;end
str2=sprintf('%s\r','R1')
HeL=query(ilm,str2);
Level(end+1,:)=[now sscanf(HeL,'R%f')];
Level=Level(Level(:,2)<1000,:);%%%No hace nada salvo cuando hay lectura errónea.

if boolplot
    auxhandle=findobj('name','He Level');
    if isempty(auxhandle) figure('name','He Level'); else figure(auxhandle);end
    plot(Level(:,1),Level(:,2)*1e-1,'o-'),dateaxis('X',15);grid on
    xlabel('hora','fontsize',12,'fontweight','bold')
    ylabel('He Level(%)','fontsize',12,'fontweight','bold')
    title('Nivel Helio Liquido','fontsize',12,'fontweight','bold')
    set(gca,'fontsize',12,'fontweight','bold');
    h=get(gca,'children');set(h,'linewidth',3,'marker','.','markersize',20)
end
Hefile=strcat(datadir,'\HeLevel')
save(Hefile,'Level');
fclose(ilm);