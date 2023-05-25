function BuildComboRun(config)
%%% Funcion para combinar datos de varios runs en un único run con la misma
%%% estructura y nombre RUN10n.
% Se necesitan rutas a run de IVs, Zs HP, Zs PXI, Noises HP y Noises PXI.
%Se puede pasar estructura config con los nombre completos de las rutas o
%fichero de configuracion json con los nombres de los RUNs.
% De momento hay que lanzarlo desde la carpeta raiz del CH en cuestion.

x=strsplit(pwd,'\');
if isempty(strfind(x{end},'CH')) error('Ejecuta desde el directorio raiz de un canal');end
basedir=pwd;
NSdir='';
if isstruct(config)%config es una estructura con las rutas completas a los runs
    IVsdir=strcat(config.IVsdir,'\IVs');%%%Elconfig.IVsdir es el directorio del run.
    HPZsdir=config.HPZsdir;
    PXIZsdir=config.PXIZsdir;
    HPNoisesdir=config.HPNoisesdir;
    PXINoisesdir=config.PXINoisesdir;
    if isfield(config,'NSdir') NSdir=config.NSdir;end
end
if ischar(config)%pasamos .jsonfile con los runs. Ver combo_config.json de ejemplo.
    data=loadjson(config);
    IVsdir=strcat(strcat(basedir,'\',upper(data.IVsrun)),'\IVs');%%%Elconfig.IVsdir es el directorio del run.
    HPZsdir=strcat(basedir,'\',upper(data.HPZsrun));
    PXIZsdir=strcat(basedir,'\',upper(data.PXIZsrun));
    HPNoisesdir=strcat(basedir,'\',upper(data.HPNoisesrun));
    PXINoisesdir=strcat(basedir,'\',upper(data.PXINoisesrun));
    if isfield(data,'NSdir') NSdir=data.NSdir;end
end
xx=size(ls('RUN1**'));
Ncomboruns=xx(1);
name=strcat('RUN1',sprintf('%02d',Ncomboruns));
mkdir(name)
%%%Copiamos IVs
copyfile(IVsdir,strcat(name,'\IVs'));
disp('Carpeta IVs copiada')

try
%%%Copiamos Zs de HP
HPZsTemps=ls(strcat(HPZsdir,'\*mK'));
aux=size(HPZsTemps);
NTemps=aux(1);
for i=1:NTemps
    copyfile(strcat(HPZsdir,'\',HPZsTemps(i,:),'\TF_*'),strcat(name,'\',HPZsTemps(i,:)));
    copyfile(strcat(HPZsdir,'\Negative Bias\',HPZsTemps(i,:),'\TF_*'),strcat(name,'\Negative Bias\',HPZsTemps(i,:)));
end
disp('Carpetas Zs HP copiadas')

%%%Copiamos Zs de PXI
PXIZsTemps=ls(strcat(PXIZsdir,'\*mK'));
aux=size(PXIZsTemps);
NTemps=aux(1);
for i=1:NTemps
    copyfile(strcat(PXIZsdir,'\',PXIZsTemps(i,:),'\PXI_TF*'),strcat(name,'\',PXIZsTemps(i,:)));
    copyfile(strcat(PXIZsdir,'\Negative Bias\',PXIZsTemps(i,:),'\PXI_TF*'),strcat(name,'\Negative Bias\',PXIZsTemps(i,:)));
end
disp('Carpetas Zs PXI copiadas')

%%%Copiamos Ruidos de HP
HPNoisesTemps=ls(strcat(HPNoisesdir,'\*mK'));
aux=size(HPNoisesTemps);
NTemps=aux(1);
for i=1:NTemps
    copyfile(strcat(HPNoisesdir,'\',HPNoisesTemps(i,:),'\HP_noise*'),strcat(name,'\',HPNoisesTemps(i,:)));
    copyfile(strcat(HPNoisesdir,'\Negative Bias\',HPNoisesTemps(i,:),'\HP_noise*'),strcat(name,'\Negative Bias\',HPNoisesTemps(i,:)));
end
disp('Carpetas Ruidos HP copiadas')

%%%Copiamos Ruidos de PXI
PXINoisesTemps=ls(strcat(PXINoisesdir,'\*mK'));
aux=size(PXINoisesTemps);
NTemps=aux(1);
for i=1:NTemps
    copyfile(strcat(PXINoisesdir,'\',PXINoisesTemps(i,:),'\PXI_noise_*'),strcat(name,'\',PXINoisesTemps(i,:)));
    copyfile(strcat(PXINoisesdir,'\Negative Bias\',PXINoisesTemps(i,:),'\PXI_noise*'),strcat(name,'\Negative Bias\',PXINoisesTemps(i,:)));
end
disp('Carpetas Ruidos PXI copiadas')

catch
    error('Revisa DIRS. Posiblemente falta algun dato.');
end

%%%%copiamos circuit estructure
[file,path]=uigetfile('*circuit*','SELECT CIRCUIT FILE');%,'Multiselect','on');
copyfile(strcat(path,file),name);

%%%Copiamos TF y ruidos de estado NS
[file,path]=uigetfile(strcat(NSdir,'*'),'SELECT NS FILES','Multiselect','on');
for i=1:length(file)
    copyfile(strcat(path,file{i}),name);
end
%%% Rellenamos .xls
xlsfile=ls('Summary_2023*.xls');%%%!
[~,txt]=xlsread(xlsfile,2,'A:A');%%%Asumimos que estamos en el dir correcto.
index=num2str(numel(txt)+1);
rango=strcat('A',index,':D',index);

aux=strsplit(IVsdir,'\');
runIVs=aux{end-1};
aux=strsplit(HPZsdir,'\');
runZsHP=aux{end};
aux=strsplit(PXIZsdir,'\');
runZsPXI=aux{end};
aux=strsplit(HPNoisesdir,'\');
runNoisesHP=aux{end};
aux=strsplit(PXINoisesdir,'\');
runNoisesPXI=aux{end};
comment=sprintf('Combo RUN. IVs from %s. Zs HP from %s. Noises HP from %s. Zs PXI from %s. Noises PXI from %s',runIVs,runZsHP,runNoisesHP,runZsPXI,runNoisesPXI);
try
    xlswrite(xlsfile,{name,0,0,comment},2,rango);
    disp('Excel actualizada')
catch Error
    mess='Error escribiendo info en .xls file. Posiblemente file abierto. Recuerda rellenar los datos a mano al final de run';
    disp(mess);
    fprintf(2,'%s\n',Error.message);
end