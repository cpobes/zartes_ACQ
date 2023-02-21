function InitDirectories(varargin)
default_data_dir='C:\Users\Athena\Desktop\Datos_Nuevo_Dilucion';
Meses={'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',...
    'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'};
cd(default_data_dir)
Thisyear=num2str(year(now));
mkdir(Thisyear)
cd(Thisyear)
Thismonth=Meses{month(now)};
if nargin==1
    Thismonth=varargin{1};
end
if ~exist(Thismonth, 'dir')
    mkdir(Thismonth);
    cd(Thismonth);
    mkdir('R(T)s')
    copyfile(strcat(default_data_dir,'\','TemplateMuestrasRT.xlsx'),...
        strcat('R(T)s/Muestras_',Thismonth,'.xlsx'));
    %%%Rellenar .xls con muestras si se pasa fichero.
    fclose(fopen('R(T)s\zstop.txt','w'));
    mkdir('SQUIDs\CH1')
    mkdir('SQUIDs\CH2')
    copyfile(strcat(default_data_dir,'\','circuit*'),'Squids');
    %%%Crear también las .xls
    disp('Carpetas Creadas para Nueva Enfriada');
else
    error('Call the function with a new Month Name');
end