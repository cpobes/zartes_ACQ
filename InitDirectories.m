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
    mkdir('RTs')
    copyfile(strcat(default_data_dir,'\','TemplateMuestrasRT.xlsx'),...
        strcat('RTs/Muestras_',Thismonth,'.xlsx'));
    fclose(fopen('RTs\zstop.txt','w'));
    mkdir('Squids\TESA')
    mkdir('Squids\TESB')
    copyfile(strcat(default_data_dir,'\','circuit*'),'Squids');
    disp('Carpetas Creadas para Nueva Enfriada');
else
    error('Call the function with a new Month Name');
end