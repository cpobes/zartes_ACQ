function varargout=Full_ACQ_wopt(file,circuit,varargin)
%%%Función para adquirir IVs y Z(w) a varias temperaturas de forma
%%%automática. versión sacando opciones a struct

if nargin==0 %show options prototype
    options.IVs.boolacq=1;
    %options.IVs.IbiasValues=[];
    %options.IVs.TempsArray=[];
    %options.IVset=[];
    %options.IVsetN=[];
    options.ICs.boolacq=0;
    options.ICs.TempsArray=[];
    options.Bscan.boolacq=0;
    options.Bscan.TempsArray=[];
    options.ZsNoise.boolacq=0;
    options.ZsNoise.TempsArray=[];
    options.ZsNoise.useFanInOut=0;
    options.ZsNoise.HPopt.TF=1;
    options.ZsNoise.HPopt.Noise=1;
    options.ZsNoise.PXIopt.TF=1;
    options.ZsNoise.PXIopt.Noise=1;
    options.ZsNoise.PXIopt.Pulses=0;
    options.optIV.Rf=1e4;
    options.optIV.sourceCH=2;
    options.optIV.sourceType='normal';
    options.optIV.boolplot=1;
    options.optIV.averages=5;
    options.optIV.useFanInOut=1;
    options.excludeList={'LKS','K220','AVS47'};
    varargout{1}=options;
    return;
end

x=strsplit(pwd,'\');
if isempty(strfind(x{end},'RUN')) error('Lanza la ACQ desde una carpeta con formato RUNnnn');end

%opciones minimas necesarias.
options.IVs.boolacq=1;
options.ICs.boolacq=0;
options.Bscan.boolacq=0;
options.ZsNoise.boolacq=0;

%default IV options
optIV.Rf=1e4;
optIV.sourceCH=2;
optIV.sourceType='normal';
optIV.boolplot=1;
optIV.averages=5;

if nargin>2
    options=varargin{1};
end

%%%Setting Log
if strcmp(get(0,'Diary'),'on') diary off;end
DiaryFile=strcat('DiaryFile_',num2str(round(now*86400)),'.log');
diary(DiaryFile);%%%Diary ON
runname=strsplit(pwd,'\');
fprintf(1,'Starting Acquisition %s at %s\n',runname{end},datestr(now));

%%%Check HW communication
x=CheckHW('PrimaryAddresses.json');
bad=[];
if isfield(options,'excludeList')
    excludeList=options.excludeList;
else
    excludeList={'LKS','K220','AVS47'};
end
%%%chequeamos instrumentos. Saltamos el LKS. Mar24 saltamos tb K220.
for i=1:length(x.Instruments) 
    %%%if strcmp(x.Instruments(i),'DSA') continue;end %%%%
    if sum(strcmp(x.Instruments(i),excludeList)) 
        continue;
    end
    if ~strcmp(x.Status(i),'OK') %%%&& ~strcmp(x.Instruments(i),'LKS') && ~strcmp(x.Instruments(i),'K220'))
        bad(end+1)=i;
    end
end
if ~isempty(bad)
    diary off;
    error('Error de Comunicación. Comprueba conexiones');
end

if(0)%%%Deshabilitamos uso K220 como fuente para la bobina. Ahora usamos LNCS.
    k220=k220_init(0);%%Ojo a cambios de Primary y GPIB.
    %%%La k220 a veces se inicializa bien, pero da error al enviar comandos. Se
    %%%corrije al comunicarse con ella desde el Ni-MAX.
    if isnan(k220_CheckOUTPUT(k220))
        diary off;
        error('K220 Init OK, but Comunication Error. Try Reset from Ni-MAX');
    end
end %%%ifk220. Ya no la usamos.Mar24.

if isfield(options,'comment')
    comment=options.comment;
else
    comment='Run soft Carlos';
end

%%% Rellenamos .xls
xlsfile=ls(strcat('../Summary_',num2str(year(now)),'*.xls'));
%xlsfile=ls('../Summary_2023*.xls');%%%!

[~,txt]=xlsread(strcat('../',xlsfile),2,'A:A');
index=num2str(numel(txt)+1);
rango=strcat('A',index,':D',index);
try
    xlswrite(strcat('../',xlsfile),{runname{end},0,0,comment},2,rango);
catch Error
    mess='Error escribiendo info en .xls file. Posiblemente file abierto. Recuerda rellenar los datos a mano al final de run';
    disp(mess);
    fprintf(2,'%s\n',Error.message);
end

if isfield(options,'optIV')
    optIV=options.optIV;
end

%%%comprobamos si el ch del squid y el del directorio coinciden
chstring=strcat('CH',num2str(optIV.sourceCH));
fc=@(x)strcmp(x,chstring);
if ~sum(cellfun(fc,runname));
    diary off;
    error('SQUID_CH and directory_CH mismatch');
end

%%%Guardamos OP del squid en options.
try
    mag=mag_init();%%%ojo, esto depende de la conf por defecto. Habría que usar la MAGstring
    squidOP=mag_GetSquidBiasPoint_CH(mag,optIV.sourceCH);
    options.squidOP=squidOP;
    fclose(mag);
catch
    diary off;
    error('Ojo default MAGdir=COM4. Error al leer squidOP');
end

if isfield(options,'IVset')
    ivauxP=options.IVset;
    ivauxN=ivauxP;
end
if isfield(options,'IVsetN')
    ivauxN=options.IVsetN;
end

%%%
if isfield(options.optIV,'useFanInOut')
    optIV.useFanInOut=options.optIV.useFanInOut;
end
%%%
if isfield(options,'Ibobina')
    options.acqInfo.ActualIbobina=SetBoptimo(options.Ibobina);
end
options.acqInfo.Start=datestr(now);
options.acqInfo.dir=pwd;

%%% Parametro de entrada fichero con lista de Tbaths
fid=fopen(file);
temps=fscanf(fid,'%f')
fclose(fid);
basedir=pwd;
%empezamos buble de medida
for i=1:length(temps)
    
    if  exist('stop.txt','file')
        varargout{1}=options;
        diary off;
        return
    end
    %%%BF set temp
    try
        BFsetPoint(temps(i));
    catch Error
        strcat('error Tb:',num2str(temps(i)))
        fprintf(2,'%s\n',Error.message);
        diary off;
        error('Tset no se ha configurado correctamente. Revisar comunicación con el BF.');
    end
    %%%El BFsetPoint ya hace una espera-> no hace falta ficheros.
    Tstring=sprintf('%0.1fmK',temps(i)*1e3);
    fprintf(1,'Tbath set to %s\n',Tstring);
%    SETstr=strcat('tmp\T',Tstring,'.stb') %%%OJO al directorio donde se pone el temps.txt!   
    
%    while(~exist(SETstr,'file'))
        %bucle para esperar a Tbath SET 
%    end

        if(options.IVs.boolacq)%%%Para medir o no IVs finas
        %%%acquireIVs. Automatizar definición de los IbiasValues.
        if isfield(options.IVs,'TempsArray')
           ivsarray=options.IVs.TempsArray;
        else
           %ivsarray=temps(1:end-1);%[0.07 0.05];
           ivsarray=temps(temps~=0);
        end
        
        if(~isempty(find(ivsarray==temps(i), 1)))
         mkdir IVs
         cd IVs
            if isfield(options.IVs,'IbiasValues')
                IbiasValues=options.IVs.IbiasValues;
            else
                IbiasValues=[500:-10:300 295:-5:200 198:-2:-10];
            end
        
            %config mag to auto reset 
            mag=mag_init();
            mag_setAutoResetON_CH(mag,9.0,optIV.sourceCH);%Ponemos umbral reset a 9V para no alterar la IV pero para evitar que salte a 10V y caliente.
            fclose(mag);
        try  %%%A veces dan error las IVs. pq?
            IVaux=acquire_Pos_Neg_Ivs(Tstring,IbiasValues,optIV);
        catch
            instrreset;
            IVaux=acquire_Pos_Neg_Ivs(Tstring,IbiasValues,optIV);
        end
        
        cd ..
        end
        end %%%if IVs
        
        %%%Para medir Icriticas%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(options.ICs.boolacq)
            if isfield(options.ICs,'TempsArray')
                auxarrayIC=options.ICs.TempsArray;
            else
                auxarrayIC=[0.076 0.077:0.0005:0.0825];
            end
            if(~isempty(find(auxarrayIC==temps(i), 1)))
                mkdir ICs
                cd ICs
                Ivalues=[0:0.25:500];
                ic(i)=measure_Pos_Neg_Ic(Tstring,Ivalues);
                cd ..
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%I criticas con BSCAN %%%%%%%%%%%%%%%%%%%%%%
        if(options.Bscan.boolacq)%%%Para hacer barrido en campo
            if isfield(options.Bscan,'TempsArray')
                auxarrayIC=options.Bscan.TempsArray;
            else
                auxarrayIC=[0.07 0.075 0.08 0.082 0.084 0.086 0.088 0.09 0.092 0.094 0.096 0.098 0.1];
            end
            
            if(~isempty(find(auxarrayIC==temps(i), 1)))
                
                if isfield(options.Bscan,'Bvalues')
                    Bvalues=options.Bscan.Bvalues;
                else
                    Bvalues=[-5000:100:6000]*1e-6;%%%<-ojo, al medir con campo tengo que reponer el campo original para seguir midiendo.
                end
                
                mkdir Barrido_Campo
                cd Barrido_Campo
                step=0.2;
                ICpairs=Barrido_fino_Ic_B(Bvalues,step);
                icstring=strcat('ICpairs',Tstring,'.mat');
                save(icstring,'ICpairs');
                cd ..
            end
        end%%% Barrido en campo
    
        %%%%%%%%%%% Z(w) y RUIDOS %%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(options.ZsNoise.boolacq) %%%Hacer o no Z(w)-Ruido.
        
        if isfield(options.ZsNoise,'TempsArray')
            auxarray=options.ZsNoise.TempsArray;
        else
            auxarray=[0.05 0.06 0.07 0.08];
        end
        
        if isfield(options.ZsNoise,'HPopt')
            HPopt=options.ZsNoise.HPopt;
            HPopt.sourceCH=optIV.sourceCH;
        else
            HPopt.TF=1;
            HPopt.Noise=1;
            HPopt.sourceCH=optIV.sourceCH;
        end
        
        if isfield(options.ZsNoise,'PXIopt')
            PXIopt=options.ZsNoise.PXIopt;
            PXIopt.sourceCH=optIV.sourceCH;
        else
            PXIopt.TF=1;
            PXIopt.Noise=1;
            PXIopt.Pulses=0;
            PXIopt.sourceCH=optIV.sourceCH;
        end
        if isfield(options.ZsNoise,'useFanInOut')
            HPopt.useFanInOut=options.ZsNoise.useFanInOut;
            PXIopt.useFanInOut=options.ZsNoise.useFanInOut;
        end
        if(~isempty(find(auxarray==temps(i), 1)))           
            mkdir(Tstring)
            cd(Tstring)           
            %%%acquire Z(w). Automatizar definición de los IZvalues
            if nargin==2 || (nargin==3 && (isstruct(varargin{1})&& ~isfield(varargin{1},'IVset')))
                IVsetP=GetIVTES(circuit,IVaux.ivp);%%%nos quedamos con la IV de bias positivo.
                IVsetN=GetIVTES(circuit,IVaux.ivn);
            else
                IVsetP=ivauxP(GetTbathIndex(temps(i)*1e3,ivauxP,ivauxP));
                IVsetN=IVsetP;IVsetN.ibias=-IVsetP.ibias;IVsetN.vout=-IVsetP.vout;%%% ad hoc
                if isfield(options,'IVsetN') IVsetN=ivauxN(GetTbathIndex(temps(i)*1e3,ivauxN,ivauxN));end
            end
            
            if isfield(options.ZsNoise,'rpp')
                rpp=options.ZsNoise.rpp;
            else
                rpp=[0.9:-0.05:0.3 0.29:-0.01:0.04];
            end
            
            if isfield(options.ZsNoise,'rpn')
                rpn=options.ZsNoise.rpn;
            else
                rpn=rpp;
            end
            IZvaluesP=BuildIbiasFromRp(IVsetP,rpp);
            IZvaluesP=IZvaluesP(abs(IZvaluesP)<500);%%%Si el spline no es bueno, puede haber valores por encima de 500uA y eso va a hacer que de error el set_Imag
            IZvaluesN=BuildIbiasFromRp(IVsetN,rpn);
            IZvaluesN=IZvaluesN(abs(IZvaluesN)<500);%%%%Para evitar error fte normal si el spline no esta bien.
            %return;
            ['Starting Z-Noise Measurements: ' datestr(now)]
            %config mag to auto reset 
            mag=mag_init();
            mag_setAutoResetON_CH(mag,1.0,optIV.sourceCH);%Ponemos umbral reset a 1V para que la pxi esté siempre en rango.
            fclose(mag);
            try
                %if HPopt.TF + HPopt.Noise
                hp_auto_acq_POS_NEG(IZvaluesP,IZvaluesN,HPopt);%%%ojo, se sube un nivel
                'HP done'
                %end
                %if(0)%%%!!!pxi not communicating
                cd(Tstring)
                pxi_auto_acq_POS_NEG(IZvaluesP,IZvaluesN,PXIopt);%%%se sube tb un nivel
                'PXI done'
                %end%%%!!!pxi not communicating
            catch Error
                strcat('error Tb:',num2str(temps(i)))
                fprintf(2,'%s\n',Error.message);
                cd(basedir)%%%!!! da error al poner cd basedir.
            end
            %cd .. %%%(en acq Z(w) se sube ya un nivel.)
        end
    end%%%%if Z(w)-Ruido.
    
    %%%esto en realidad ya no es necesario.
%     DONEstr=strcat('T',Tstring,'.end')  
%     cd tmp
%     f = fopen(DONEstr, 'w' );  
%     fclose(f);
%     cd ..
end
options.acqInfo.Stop=datestr(now);
options.circuit=circuit;
save(strcat('AcqOptions_',num2str(round(now*86400))),'options')
fprintf(1,'Stopping Acquisition %s at %s\n',runname{end},datestr(now));
diary off