function varargout=Full_ACQ_wopt(file,circuit,varargin)
%%%Función para adquirir IVs y Z(w) a varias temperaturas de forma
%%%automática. versión sacando opciones a struct
if nargin==0 %show options prototype
    options.IVs.boolacq=1;
    options.IVs.IbiasValues=[];
    options.IVs.TempsArray=[];
    options.IVset=[];
    options.IVsetN=[];
    options.ICs.boolacq=0;
    options.ICs.TempsArray=[];
    options.Bscan.boolacq=0;
    options.Bscan.TempsArray=[];
    options.ZsNoise.boolacq=1;
    options.ZsNoise.TempsArray=[];
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
    varargout{1}=options;
    return;
end
%%% Parametro de entrada fichero con lista de Tbaths
fid=fopen(file)
temps=fscanf(fid,'%f')
fclose(fid)
basedir=pwd;

%opciones minimas necesarias.
options.IVs.boolacq=1;
options.ICs.boolacq=0;
options.Bscan.boolacq=0;
options.ZsNoise.boolacq=1;

if nargin>2
    options=varargin{1};
end

%default IV options
optIV.Rf=1e4;
optIV.sourceCH=2;
optIV.sourceType='normal';
optIV.boolplot=1;
optIV.averages=5;

if isfield(options,'optIV')
    optIV=options.optIV;
end

if isfield(options,'IVset')
    ivauxP=options.IVset;
    ivauxN=IVauxP;
end
if isfield(options,'IVsetN')
    ivauxN=options.IVsetN;
end

options.acqInfo.Start=datestr(now);
optiond.acqInfo.dir=pwd;
%empezamos buble de medida
for i=1:length(temps)
    
    %%%BF set temp
    BFsetPoint(temps(i));
    Tstring=sprintf('%0.1fmK',temps(i)*1e3)
    SETstr=strcat('tmp\T',Tstring,'.stb') %%%OJO al directorio donde se pone el temps.txt!   
    
    while(~exist(SETstr,'file') & ~exist('stop.txt','file'))
        %bucle para esperar a Tbath SET 
    end

        if(options.IVs.boolacq)%%%Para medir o no IVs finas
        %%%acquireIVs. Automatizar definición de los IbiasValues.
        if isfield(options.IVs,'TempsArray')
           ivsarray=options.IVs.TempsArray;
        else
           ivsarray=temps(1:end-1);%[0.07 0.05]; 
        end
        
        if(~isempty(find(ivsarray==temps(i), 1)))
         mkdir IVs
         cd IVs
            if isfield(options.IVs,'IbiasValues')
                IbiasValues=options.IVs.IbiasValues;
            else
                IbiasValues=[500:-10:300 295:-5:200 198:-2:-10];
            end

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
        else
            HPopt.TF=1;
            HPopt.Noise=1;
        end
        
        if isfield(options.ZsNoise,'PXIopt')
            PXIopt=options.ZsNoise.PXIopt;
        else
            PXIopt.TF=1;
            PXIopt.Noise=1;
            PXIopt.Pulses=0;
        end
        
        if(~isempty(find(auxarray==temps(i), 1)))           
            mkdir(Tstring)
            cd(Tstring)           
            %%%acquire Z(w). Automatizar definición de los IZvalues
            if nargin==2 || (nargin==3 && isstruct(varargin{1}))
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
            rpn=rpp;
            
            IZvaluesP=BuildIbiasFromRp(IVsetP,rpp);
            IZvaluesP=IZvaluesP(abs(IZvaluesP)<500);%%%Si el spline no es bueno, puede haber valores por encima de 500uA y eso va a hacer que de error el set_Imag
            IZvaluesN=BuildIbiasFromRp(IVsetN,rpn);
            IZvaluesN=IZvaluesN(abs(IZvaluesN)<500);%%%%Para evitar error fte normal si el spline no esta bien.
            try
                hp_auto_acq_POS_NEG(IZvaluesP,IZvaluesN,HPopt);%%%ojo, se sube un nivel
                'HP done'
                
                cd(Tstring)
                pxi_auto_acq_POS_NEG(IZvaluesP,IZvaluesN,PXIopt);%%%se sube tb un nivel
                'PXI done'
            catch
                strcat('error Tb:',num2str(temps(i)))
                cd(basedir)%%%!!! da error al poner cd basedir.
            end
            %cd .. %%%(en acq Z(w) se sube ya un nivel.)
        end
    end%%%%if Z(w)-Ruido.
    
    DONEstr=strcat('T',Tstring,'.end')  
    cd tmp
    f = fopen(DONEstr, 'w' );  
    fclose(f);
    cd ..
end
options.acqInfo.Stop=datestr(now);
save(strcat('AcqOptions_',num2str(round(now*86400))),'options')