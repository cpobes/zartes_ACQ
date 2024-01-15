function out=CheckHW(varargin)
%%%funcion para chequear el HW activo en prevision de inicializar
%%%automaticamente.
%%%V0 22-Oct-2021 funciona correctamente, pero programacion algo cumbersome
%%%(seria mucho mas compacto seguramente con dictionaries!). 
%%% Falta por incorporar la PXI que no se puede chequear con instrhwinfo y
%%% la posibilidad de leer las direcciones primarias de fichero (no
%%% prioritario).

%ACQDIR='C:\Users\Athena\Desktop\Software\zartes_ACQ';
ACQDIR='C:\Users\nico\Documents\GitHub\zartes_ACQ';

Instruments={'Multimetro' 'DSA' 'K220' 'LKS' 'AVS47' 'Magnicon' 'PXI' 'BlueFors'}';

if nargin==1
    AdressFile=varargin{1};%%%%Only JSON file!
    file=strcat(ACQDIR,'\',AdressFile);
    try
        data=loadjson(file);
    catch
        error('Invalid file format. Use a .json file');
    end
    multiPA=data.GPIB.multi;
    dsaPA=data.GPIB.dsa;
    k220PA=data.GPIB.k220;
    LKSPA=data.GPIB.LKS;
    AVS47PA=data.GPIB.AVS47;
    magCOMstr=data.SERIAL.mag;
    PXIname=data.PXI.pxi5922;
else
    %%%GPIB Primary Addresses.
    multiPA=4;
    dsaPA=11;
    k220PA=2;
    LKSPA=12;
    AVS47PA=21;
    magCOM=4;%serial.usually COM5; 
    magCOMstr=strcat('COM',magCOM);
    PXIname='PXI1Slot3';
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
    mag=mag_init(magCOMstr);
    aux=mag_info(mag);
    if isempty(aux) magString=nofound; else magString='OK';end
    fclose(mag);
    delete(mag);
    clear mag %solo lo usamos para chequear si está la electronica conectada.
catch
    magString=nofound;
end
%%%%PXI card Check
try 
    pxi=PXI_init(PXIname);
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

out=table(Instruments,Status);