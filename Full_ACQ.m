function Full_ACQ(file,circuit,varargin)
%%%Funci�n para adquirir IVs y Z(w) a varias temperaturas de forma
%%%autom�tica a trav�s de un fichero de comunicaci�n compartido con el
%%%control de temperatura. Necesitamos pasar el circuit con Rn si queremos
%%%que se cargue la estructura IVset completa con la que poder extraer los
%%%valores de IZvalues a %Rn determinados. Eso implica medir una IV en
%%%estado S y otra en estado N para sacar Rpar y Rn.

%%%% Versi�n 1. Con ficheros vac�os de distinto nombre
%%% Parametro de entrada fichero con lista de Tbaths
fid=fopen(file)
temps=fscanf(fid,'%f')
fclose(fid)

%circuit %%%si circuit no est� cargado dar� error al principio de ejecuci�n. Antes empezaba las IVs y pod�a dar error solo al empezar las Z(w).
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
    BFsetPoint(temps(i));
    
    %SETstr=strcat('tmp\T',num2str(1e3*temps(i)),'mK.stb')
    Tstring=sprintf('%0.1fmK',temps(i)*1e3)
    SETstr=strcat('tmp\T',Tstring,'.stb') %%%OJO al directorio donde se pone el temps.txt!
    
    
    while(~exist(SETstr,'file') & ~exist('stop.txt','file'))
        %bucle para esperar a Tbath SET 
    end

        if(1)%%%Para medir o no IVs finas
        %%%acquireIVs. Automatizar definici�n de los IbiasValues.
        %%%Ibias.Ib130=[500:-20:240 235:-5:135 134:-0.5:90 80:-20:0]
        %ivsarray=[0.04 0.045 0.05 0.055 0.06 0.065 0.07 0.075 0.08:0.002:0.12]; 
        %ivsarray=[0.035 0.04 0.045 0.05 0.055 0.06 0.065 0.07 0.075 0.077 0.078 0.079 0.08 0.081 0.082 0.09 0.095 0.1 0.105 0.11];
        %ivsarray=[0.04 0.045 0.055 0.06 0.065 0.07 0.075 0.080 0.085 0.09 0.095 0.1 0.102 0.104 0.106 0.108 0.110 0.112 0.114 0.115 0.12 0.125];
        %ivsarray=[0.04 0.045 0.050 0.055 0.060 0.065 0.070 0.075 0.076 0.077 0.078 0.079 0.080 0.081 0.082 0.085 0.090 0.1];
        ivsarray=temps(1:end-1);%[0.07 0.05];
        %ivsarray=[];
        if(~isempty(find(ivsarray==temps(i), 1)))
         mkdir IVs
         cd IVs
        
         %IbiasValues=[500:-10:150 145:-5:130 129:-1:80 79.9:-0.1:0];%%%!!!!Crear funcion!!!!
         %IbiasValues=[500:-10:200 195:-5:150 149:-1:0 -0.05:-0.05:-1];
         
         IbiasValues=[500:-10:300 295:-5:200 198:-2:-10];
         
         %IbiasValues=[200:-5:100 98:-2:50 49.5:-0.5:0];
         %imin=10+4*(i-1);
         %IbiasValues=[500:-10:300 295:-5:200 198:-2:100 99:-0.5:imin 10:-1:0];%%%!!!!Crear funcion!!!!
         
%          if temps(i)==0.040 %%%%Buscamos PSL en la de 40mK.
%              IbiasValues=[500:-10:200 195:-5:150 148:-2:100 99:-1:70 69.9:-0.01:0];
%          end
%          if temps(i)<0.075
%              IbiasValues=[500:-10:300 295:-5:250 249:-1:0];
%          end
%         if temps(i)<0.072
%             IbiasValues=[500:-20:200 195:-5:150 149.5:-0.5:0]; %%%Deber�a saltar al detectar el estado S.
%         elseif temps(i)<0.08
%             IbiasValues=[500:-20:200 190:-10:150 148:-2:100 99.5:-0.5:0]; %%%Deber�a saltar al detectar el estado S.
%         else
%             IbiasValues=[500:-20:100 95:-5:60 59.5:-0.5:0];
%         end
        

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
        
        if(0)%%%Para hacer barrido en campo
        auxarrayIC=[0.07 0.075 0.08 0.082 0.084 0.086 0.088 0.09 0.092 0.094 0.096 0.098 0.1];
        %auxarrayIC=temps;%(1:4);
        %auxarrayIC=temps(2:end);%%%Para hacer barrido en campo%%%%%%%%%%%%%%%%%%%
        if(~isempty(find(auxarrayIC==temps(i), 1)))
            %Bvalues=[0:40:2500]*1e-6;
            Bvalues=[-5000:100:6000]*1e-6;%%%<-ojo, al medir con campo tengo que reponer el campo original para seguir midiendo.
%             if temps(i)<72e-3
%                 step=5;
% %             elseif temps(i)>=85e-3 &&temps(i)<88e-3
% %                 step=2;
%             elseif temps(i)<79e-3 && temps(i)>=72e-3
%                 step=0.5;
%             elseif temps(i)>=79e-3
%                 step=0.2;
%             end
            mkdir Barrido_Campo
            cd Barrido_Campo
            step=0.2;
            ICpairs=Barrido_fino_Ic_B(Bvalues,step)
            icstring=strcat('ICpairs',Tstring,'.mat');
            save(icstring,'ICpairs');
            cd ..
        end
        end%%% Barrido en campo
        
%%%definimos un array con temperaturas a las que adquirir Z(w)-ruido, que
%%%puede ser un subconjunto de las Tbath a las que se mida IV.
    %auxarray=[0.04 0.045 0.05 0.055 0.06 0.065 0.07 0.075 0.08 0.085 0.09];    
    
    if(0) %%%Hacer o no Z(w)-Ruido.
    %auxarray=temps(1:end-1);
    auxarray=[0.05 0.06 0.07 0.08];
        if(~isempty(find(auxarray==temps(i), 1)))
%             mkdir Z(w)-Ruido
%             cd Z(w)-Ruido

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
            %%%acquire Z(w). Automatizar definici�n de los IZvalues

            if nargin==2
            IVsetP=GetIVTES(circuit,IVaux.ivp);%%%nos quedamos con la IV de bias positivo.
            IVsetN=GetIVTES(circuit,IVaux.ivn);
            else
                IVsetP=ivauxP(GetTbathIndex(temps(i)*1e3,ivauxP,ivauxP));
                IVsetN=IVsetP;IVsetN.ibias=-IVsetP.ibias;IVsetN.vout=-IVsetP.vout;%%% ad hoc
                if nargin>3 IVsetN=ivauxN(GetTbathIndex(temps(i)*1e3,ivauxN,ivauxN));end
            end
            
            %rpp=[0.9:-0.05:0.02 0.19:-0.01:0.05]; %%%Vector con los puntos donde tomar Z(w).
            %rpp=[0.9:-0.05:0.3 0.28:-0.02:0.1];% 0.18:-0.02:0.04];
            
            rpp=[ 0.9:-0.05:0.3 0.29:-0.01:0.04];
            %rpp=0.8;%%%debug.
%             if temps(i)==0.050 %%% || temps(i)==0.07 
%                 rpp=[0.21:-0.01:0.01];
%             end
            %rpn=[0.90:-0.1:0.1];
            rpn=rpp;
            IZvaluesP=BuildIbiasFromRp(IVsetP,rpp);
            IZvaluesP=IZvaluesP(abs(IZvaluesP)<500);%%%Si el spline no es bueno, puede haber valores por encima de 500uA y eso va a hacer que de error el set_Imag
            IZvaluesN=BuildIbiasFromRp(IVsetN,rpn);
            IZvaluesN=IZvaluesN(abs(IZvaluesN)<500);%%%%Para evitar error fte normal si el spline no esta bien.
            try
                hp_auto_acq_POS_NEG(IZvaluesP,IZvaluesN);%%%ojo, se sube un nivel
                'HP done'
                
                 cd(Tstring)
                 pxi_auto_acq_POS_NEG(IZvaluesP,IZvaluesN);%%%se sube tb un nivel
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