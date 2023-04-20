function InitDirectories(varargin)
%%%Funcion para inicializar toda la estructura de carpetas de una enfriada.
%%% Se puede pasar fichero .json de configuracion con las muestras.
calldir=pwd;
default_data_dir='C:\Users\Athena\Desktop\Datos_Nuevo_Dilucion';
Meses={'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',...
    'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'};
cd(default_data_dir)
Thisyear=num2str(year(now));
mkdir(Thisyear)
Thismonth=Meses{month(now)};
data=[];
configfile='';
for i=1:nargin
    n=numel(strsplit(varargin{i},'.'));
    if n==1 %%pasamos string con nombre, pero sin extensión
        Thismonth=varargin{1};
    end
    if n==2 %%pasamos fichero de configuración json
            try
                configfile=varargin{i};
                data=loadjson(configfile);
            catch
                error('Invalid file format. Use a .json file');
            end
    end
end
cd(Thisyear)
if ~exist(Thismonth, 'dir')
    mkdir(Thismonth);
    cd(Thismonth);
    %jsave(strcat('Init_',Thismonth,'_',Thisyear),'vars',{'data'});
    if ~isempty(configfile) copyfile(strcat(calldir,'/',configfile),strcat(pwd,'/','Init_',Thismonth,'_',Thisyear,'.json'));end
    mkdir('R(T)s')
    Newxls=strcat('R(T)s/Muestras_',Thisyear,'_',Thismonth,'.xlsx');
    copyfile(strcat(default_data_dir,'\','TemplateMuestrasRT.xlsx'),...
        Newxls);
    %%%Rellenar .xls con muestras si se pasa fichero.
    if ~isempty(data) UpdateRTxls(Newxls,data);end
    fclose(fopen('R(T)s\zstop.txt','w'));
    mkdir('SQUIDs\CH1')
    mkdir('SQUIDs\CH2')
    copyfile(strcat(default_data_dir,'\','circuit*'),'SQUIDs');
    %%%Crear también las .xls
    %cd('SQUIDs\CH1')
    %%%slightly cumbersome because I started with 'Summary*' to avoid full
    %%%name, but this forced the creation of a folder instead of a file.
    NewSquidxls=strcat('Summary_',Thisyear,'_',Thismonth,'_CH1','.xls');
    copyfile(strcat(default_data_dir,'\','Summary_Desktop_Datos_Nuevo_Dilucion.xls'),'SQUIDs\CH1');
    cd('SQUIDs/CH1')
    movefile('Summary_Desktop_Datos_Nuevo_Dilucion.xls',NewSquidxls);%%En 1 solo paso no funciona.
    %copyfile(strcat(default_data_dir,'\','Summary*'),NewSquidxls);
    if ~isempty(data) UpdateSquidxls(NewSquidxls,data);end
    delete('Summary_Desktop_Datos_Nuevo_Dilucion.xls')
    cd('../..')
    NewSquidxls=strcat('Summary_',Thisyear,'_',Thismonth,'_CH2','.xls');
    copyfile(strcat(default_data_dir,'\','Summary_Desktop_Datos_Nuevo_Dilucion.xls'),'SQUIDs\CH2');
    cd('SQUIDs/CH2')
    copyfile('Summary_Desktop_Datos_Nuevo_Dilucion.xls',NewSquidxls);%%En 1 solo paso no funciona.
    if ~isempty(data) UpdateSquidxls(NewSquidxls,data);end
    delete('Summary_Desktop_Datos_Nuevo_Dilucion.xls')
    cd('../..')
    disp('Carpetas Creadas para Nueva Enfriada');
else
    error('Call the function with a new Month Name');
end