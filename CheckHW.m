function CheckHW(varargin)
%%%funcion para chequear el HW activo en prevision de inicializar
%%%automaticamente.
%%%V0 22-Oct-2021 funciona correctamente, pero programacion algo cumbersome
%%%(seria mucho mas compacto seguramente con dictionaries!). 
%%% Falta por incorporar la PXI que no se puede chequear con instrhwinfo y
%%% la posibilidad de leer las direcciones primarias de fichero (no
%%% prioritario).

Instruments={'Multimetro' 'DSA' 'K220' 'LKS' 'AVS47' 'Magnicon' 'PXI' 'BlueFors'}';

if nargin==1
    %AdressFile=varargin{1};%%%%Pdte de implementar
else
    %%%GPIB Primary Addresses.
    multiPA=4;
    dsaPA=11;
    k220PA=2;
    LKSPA=12;
    AVS47PA=21;
    magCOM=4;%serial.usually COM5; 
end

nofound='NOT FOUND';
multiString=nofound;
dsaString=nofound;
k220String=nofound;
LKSString=nofound;
AVSString=nofound;
magString='UNKNOWN';
pxiString='UNKNOWN';

info=instrhwinfo('visa','ni');

for i=1:length(info.ObjectConstructorName)
    %info.ObjectConstructorName(i)
    multiStatus=strfind(info.ObjectConstructorName(i),strcat('::',num2str(multiPA),'::'));
    %if multiStatus{1} multiString='OK'; else multiString='NOT FOUND';end
    if ~isempty(multiStatus{1})&&strcmp(multiString,'NOT FOUND') multiString='OK';end
        
    dsaStatus=strfind(info.ObjectConstructorName(i),strcat('::',num2str(dsaPA),'::'));
    %if dsaStatus{1} dsaString='OK'; else dsaString='NOT FOUND';end
    if ~isempty(dsaStatus{1})&&strcmp(dsaString,'NOT FOUND') dsaString='OK';end
        
    k220Status=strfind(info.ObjectConstructorName(i),strcat('::',num2str(k220PA),'::'));
    %if k220Status{1} k220String='OK'; else k220String='NOT FOUND';end
    if ~isempty(k220Status{1})&&strcmp(k220String,'NOT FOUND') k220String='OK';end
    
    LKSStatus=strfind(info.ObjectConstructorName(i),strcat('::',num2str(LKSPA),'::'));
    %if LKSStatus{1} LKSString='OK'; else LKSString='NOT FOUND';end
    if ~isempty(LKSStatus{1})&&strcmp(LKSString,'NOT FOUND') LKSString='OK';end
    
    AVSStatus=strfind(info.ObjectConstructorName(i),strcat('::',num2str(AVS47PA),'::'));
    %if AVSStatus{1} AVSString='OK'; else AVSString='NOT FOUND';end
    if ~isempty(AVSStatus{1})&&strcmp(AVSString,'NOT FOUND') AVSString='OK';end
    
    %%%el puerto serie se lista siempre aunque la electronica este apagada.
%     magStatus=strfind(info.ObjectConstructorName(i),strcat('ASRL',num2str(magCOM)));
%     %if magStatus{1} magString='OK'; else magString='NOT FOUND';end
%     if ~isempty(magStatus{1})&&strcmp(magString,'NOT FOUND') magString='OK';end
end

%%%%Magnicon electronics Check
try
    mag=mag_init(strcat('COM',num2str(magCOM)));
    aux=mag_info(mag);
    if isempty(aux) magString=nofound; else magString='OK';end
    fclose(mag)
    delete(mag)
    clear mag %solo lo usamos para chequear si está la electronica conectada.
catch
    magString=nofound;
end
%%%%PXI card Check
try 
    pxi=PXI_init();
    pxiString='OK';
    disconnect(pxi)
    delete(pxi)
    clear pxi
catch
    pxiString=nofound;
end

%%%BF check
uri='http://192.168.2.121:5001/channel/measurement/latest';
try
    x=webread(uri);
    BFString=x.status;
catch
    BFString=nofound;
end

Status={multiString dsaString k220String LKSString AVSString magString pxiString BFString}';

table(Instruments,Status)