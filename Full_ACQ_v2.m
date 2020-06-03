function Full_ACQ(file,circuit,varargin)
%%%Función para adquirir IVs y Z(w) a varias temperaturas de forma
%%%automática a través de un fichero de comunicación compartido con el
%%%control de temperatura. Necesitamos pasar el circuit con Rn si queremos
%%%que se cargue la estructura IVset completa con la que poder extraer los
%%%valores de IZvalues a %Rn determinados. Eso implica medir una IV en
%%%estado S y otra en estado N para sacar Rpar y Rn.

%%%% Versión 1. Con ficheros vacíos de distinto nombre
%%% Parametro de entrada fichero con lista de Tbaths

%%% Version v2. incorporo opciones a hp_auto_acq y pxi_auto_acq para poder
%%% modificar el protocolo de barrido.

fid=fopen(file);
temps=fscanf(fid,'%f')
fclose(fid);

%circuit %%%si circuit no está cargado dará error al principio de ejecución. Antes empezaba las IVs y podía dar error solo al empezar las Z(w).
%%%No da error si recnoce la clase circuit.

basedir=pwd;

if nargin>2
    ivauxP=varargin{1};
end
if nargin>3
    ivauxN=varargin{2};
end

optIV.Rf=1e4;
optIV.sourceCH=2;
optIV.sourceType='normal';
optIV.boolplot=1;
optIV.averages=5;


for i=1:length(temps)

    %SETstr=strcat('tmp\T',num2str(1e3*temps(i)),'mK.stb')
    Tstring=sprintf('%0.1fmK',temps(i)*1e3)
    SETstr=strcat('tmp\T',Tstring,'.stb') %%%OJO al directorio donde se pone el temps.txt!
    
    
    while(~exist(SETstr,'file'))
        %bucle para esperar a Tbath SET 
    end
        
        %%%Para medir o no IVs finas  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(0)
        %%%acquireIVs. Automatizar definición de los IbiasValues.
        ivsarray=temps(1:end);%[0.07 0.05];
        
        if(~isempty(find(ivsarray==temps(i), 1)))
         mkdir IVs
         cd IVs
        
         %IbiasValues=[500:-10:150 145:-5:130 129:-1:80 79.9:-0.1:0];%%%!!!!Crear funcion!!!!
         IbiasValues=[500:-10:200 195:-5:150 149:-1:0 -0.05:-0.05:-1];
        

        try  %%%A veces dan error las IVs. pq?
             IVaux=acquire_Pos_Neg_Ivs(Tstring,IbiasValues,optIV);
        catch
            instrreset;
            IVaux=acquire_Pos_Neg_Ivs(Tstring,IbiasValues,optIV);
        end
        
        cd ..
        end
        end %%%if IVs
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %%%Para medir Icriticas%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(0) %%%temps(i)>0.080
            auxarrayIC=[0.076 0.077:0.0005:0.0825];
            if(~isempty(find(auxarrayIC==temps(i), 1)))
                mkdir ICs
                cd ICs
                Ivalues=[0:0.25:500];
                ic(i)=measure_Pos_Neg_Ic(Tstring,Ivalues);
                cd ..
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(1)%%%Para hacer barrido en campo
            %auxarrayIC=[0.07 0.075 0.08 0.082 0.084 0.086 0.088 0.09 0.092 0.094 0.096 0.098 0.1];
            auxarrayIC=temps(2:end-1);
            if(~isempty(find(auxarrayIC==temps(i), 1)))
                %Bvalues=[0:40:2500]*1e-6;
                Bvalues=[-3000:100:3000]*1e-6;%%%<-ojo, al medir con campo tengo que reponer el campo original para seguir midiendo.
                %Bvalues=[-5000:100:6000]*1e-6;
                mkdir Barrido_Campo
                cd Barrido_Campo
                step=0.2;
                try
                    ICpairs=Barrido_fino_Ic_B(Bvalues,step);
                catch
                    ICpairs=load('ICpairs');
                end
                icstring=strcat('ICpairs',Tstring,'.mat');
                save(icstring,'ICpairs');
                cd ..
            end
        end%%% Barrido en campo
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    
    if(0) %%%Hacer o no Z(w)-Ruido.
     auxarray=[0.05 0.07];%%%Las Temperaturas atomar TF-Ruido.
     
        if(~isempty(find(auxarray==temps(i), 1)))

            if(0) %%%adquirir o no una IV coarse. nargin==2
                %imin=90-5*(i);%%%ojo si se reejecuta. Asume 50,55,70,75 i=1:4.
                %IbiasCoarseValues=[500:-1:0];
                IbiasCoarseValues=[500:-10:200 195:-5:150 149:-1:0];
                mkdir IVcoarse
                cd IVcoarse
                try  %%%A veces dan error las IVs. pq?
                    IVaux=acquire_Pos_Neg_Ivs(Tstring,IbiasCoarseValues,optIV);
                catch
                    instrreset;
                    IVaux=acquire_Pos_Neg_Ivs(Tstring,IbiasCoarseValues,optIV);
                end
                cd ..
            end
            
            mkdir(Tstring)
            cd(Tstring)%%%La adquisicion de Z(w) comienza en el directorio de cada Tbath
            %%%y vuelve al superior
            %%%acquire Z(w). Automatizar definición de los IZvalues

            if nargin==2
            IVsetP=GetIVTES(circuit,IVaux.ivp);%%%nos quedamos con la IV de bias positivo.
            IVsetN=GetIVTES(circuit,IVaux.ivn);
            else
                IVsetP=ivauxP(GetTbathIndex(temps(i)*1e3,ivauxP,ivauxP));
                IVsetN=IVsetP;IVsetN.ibias=-IVsetP.ibias;IVsetN.vout=-IVsetP.vout;%%% ad hoc
                if nargin>3 IVsetN=ivauxN(GetTbathIndex(temps(i)*1e3,ivauxN,ivauxN));end
            end
            
            %rpp=[0.9:-0.05:0.02 0.19:-0.01:0.05]; %%%Vector con los puntos donde tomar Z(w).
            rpp=[0.9:-0.05:0.3 0.28:-0.02:0.1];% 0.18:-0.02:0.04];
            rpn=[0.90:-0.05:0.1];
            %rpn=rpp;
            
            IZvaluesP=unique(BuildIbiasFromRp(IVsetP,rpp));%Si hay Ib<Ibmin se pone a cero, no queremos que repita.
            IZvaluesP=IZvaluesP(abs(IZvaluesP)<500);%%%Si el spline no es bueno, puede haber valores por encima de 500uA y eso va a hacer que de error el set_Imag
            IZvaluesN=unique(BuildIbiasFromRp(IVsetN,rpn));
            IZvaluesN=IZvaluesN(abs(IZvaluesN)<500);%%%%Para evitar error fte normal si el spline no esta bien.
           
            try             
                
                %%%TFacq
                dsa=hp_init();%%%necesitamos una instancia al dsa para poder configurar.
                HPopt.TF=0;HPopt.Noise=0;
                hp_ss_config(dsa);
                hp_auto_acq(IZvaluesP,HPopt)
                
                d=pwd;                
                temp=regexp(d,'\d*.?\d*mK','match');%%%Regexp correcta para reconocer tanto 50mK como 50.0mK
                mkdir(strcat('../Negative Bias/',temp{1}));%%%Crea el directorio para las Z(w) con Ibias negativa.
                cd(strcat('../Negative Bias/',temp{1}));
                %HPopt.TF=1;HPopt.Noise=0;
                hp_auto_acq(IZvaluesN,HPopt)
                cd('../..');
                cd(Tstring)
                
                %%%TF PXI
                PXIopt.TF=1;PXIopt.Npise=0;
                pxi_auto_acq(IZvaluesP,PXIopt);
                cd(strcat('../Negative Bias/',temp{1}));
                pxi_auto_acq(IZvaluesN,PXIopt);
                cd('../..');
                cd(Tstring)
                
                %%%Noiseacq
                HPopt.TF=0;HPopt.Noise=0;
                dsa=hp_init();%%%El hp_auto y pxi_auto cierran comunicación con el dsa. Necesitamos recuperarla para reconfigurar.
                hp_noise_config(dsa);
                hp_auto_acq(IZvaluesP,HPopt)
                
                d=pwd;                
                temp=regexp(d,'\d*.?\d*mK','match');%%%Regexp correcta para reconocer tanto 50mK como 50.0mK
                mkdir(strcat('../Negative Bias/',temp{1}));%%%Crea el directorio para las Z(w) con Ibias negativa.
                cd(strcat('../Negative Bias/',temp{1}));
                %HPopt.TF=0;HPopt.Noise=1;
                hp_auto_acq(IZvaluesN,HPopt)
                cd('../..');
                
                %%%PXI Noise
                cd(Tstring);
                PXIopt.TF=0;PXIopt.Noise=1;
                pxi_auto_acq(IZvaluesP,PXIopt);
                cd(strcat('../Negative Bias/',temp{1}));
                pxi_auto_acq(IZvaluesN,PXIopt);
                cd('../..');
               
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