function Full_ACQ(file,circuit,varargin)
%%%Función para adquirir IVs y Z(w) a varias temperaturas de forma
%%%automática a través de un fichero de comunicación compartido con el
%%%control de temperatura. Necesitamos pasar el circuit con Rn si queremos
%%%que se cargue la estructura IVset completa con la que poder extraer los
%%%valores de IZvalues a %Rn determinados. Eso implica medir una IV en
%%%estado S y otra en estado N para sacar Rpar y Rn.

%%%% Versión 1. Con ficheros vacíos de distinto nombre
%%% Parametro de entrada fichero con lista de Tbaths
fid=fopen(file)
temps=fscanf(fid,'%f')
fclose(fid)

basedir=pwd;

if nargin>2
    ivauxP=varargin{1};
end
if nargin>3
    ivauxN=varargin{2};
end

for i=1:length(temps)

    %SETstr=strcat('tmp\T',num2str(1e3*temps(i)),'mK.stb')
    Tstring=sprintf('%0.1fmK',temps(i)*1e3)
    SETstr=strcat('tmp\T',Tstring,'.stb') %%%OJO al directorio donde se pone el temps.txt!
    
    
    while(~exist(SETstr,'file'))
        %bucle para esperar a Tbath SET 
    end


        %%%acquireIVs. Automatizar definición de los IbiasValues.
        %%%Ibias.Ib130=[500:-20:240 235:-5:135 134:-0.5:90 80:-20:0]
        %ivsarray=[0.04 0.045 0.05 0.055 0.06 0.065 0.07 0.075 0.08:0.002:0.12]; 
        %ivsarray=[0.035 0.04 0.045 0.05 0.055 0.06 0.065 0.07 0.075 0.077 0.078 0.079 0.08 0.081 0.082 0.09 0.095 0.1 0.105 0.11];
        %ivsarray=[0.04 0.045 0.055 0.06 0.065 0.07 0.075 0.080 0.085 0.09 0.095 0.1 0.102 0.104 0.106 0.108 0.110 0.112 0.114 0.115 0.12 0.125];
        %ivsarray=[0.04 0.045 0.050 0.055 0.060 0.065 0.070 0.075 0.076 0.077 0.078 0.079 0.080 0.081 0.082 0.085 0.090 0.1];
        %ivsarray=temps;%[0.07 0.05];
        ivsarray=[];
        if(~isempty(find(ivsarray==temps(i), 1)))
         mkdir IVs
         cd IVs
        
         %IbiasValues=[500:-10:150 145:-5:130 129:-1:80 79.9:-0.1:0];%%%!!!!Crear funcion!!!!
         %IbiasValues=[500:-10:200 195:-5:100 99:-1:75 74.9:-0.1:0];
         IbiasValues=[200:-5:100 98:-2:50 49.5:-0.5:0];
         %imin=10+4*(i-1);
         %IbiasValues=[500:-10:300 295:-5:200 198:-2:100 99:-0.5:imin 10:-1:0];%%%!!!!Crear funcion!!!!
         
%          if temps(i)>100
%              IbiasValues=[500:-10:50 49:-1:0];
%          end
         if temps(i)==120
             IbiasValues=[500:-10:0];
         end
%         if temps(i)<0.072
%             IbiasValues=[500:-20:200 195:-5:150 149.5:-0.5:0]; %%%Debería saltar al detectar el estado S.
%         elseif temps(i)<0.08
%             IbiasValues=[500:-20:200 190:-10:150 148:-2:100 99.5:-0.5:0]; %%%Debería saltar al detectar el estado S.
%         else
%             IbiasValues=[500:-20:100 95:-5:60 59.5:-0.5:0];
%         end
        
        try  %%%A veces dan error las IVs. pq?
             IVaux=acquire_Pos_Neg_Ivs(Tstring,IbiasValues);
        catch
            instrreset;
            IVaux=acquire_Pos_Neg_Ivs(Tstring,IbiasValues);
        end
        
        cd ..
        end
        
        %%%Para medir Icriticas%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(0) %%%temps(i)>0.080
        mkdir ICs
        cd ICs
        Ivalues=[0:0.25:500];
        ic(i)=measure_Pos_Neg_Ic(Tstring,Ivalues);
        cd ..
        end
        
        %auxarrayIC=[0.06 0.065 0.075];
        auxarrayIC=temps;
        %auxarrayIC=[];%%%Para hacer barrido en campo%%%%%%%%%%%%%%%%%%%
        if(~isempty(find(auxarrayIC==temps(i), 1)))
            %Bvalues=[0:40:2500]*1e-6;
            Bvalues=[-3000:25:4000]*1e-6;
            if temps(i)<90e-3
                step=5;
            elseif temps(i)>=90e-3 &&temps(i)<95e-3
                step=2;
            elseif temps(i)<100e-3 && temps(i)>=95e-3
                step=1;
            elseif temps(i)>=100e-3
                step=0.2;
            end
            ICpairs=Barrido_fino_Ic_B(Bvalues,step)
            icstring=strcat('ICpairs',Tstring);
            save(icstring,'ICpairs');
        end
        
%%%definimos un array con temperaturas a las que adquirir Z(w)-ruido, que
%%%puede ser un subconjunto de las Tbath a las que se mida IV.
    %auxarray=[0.04 0.045 0.05 0.055 0.06 0.065 0.07 0.075 0.08 0.085 0.09];    
    
    auxarray=[0.05 0.070];
    %auxarray=[0.05 0.055 0.070 0.075];
        if(~isempty(find(auxarray==temps(i), 1)))
%             mkdir Z(w)-Ruido
%             cd Z(w)-Ruido

            if(0) %%%adquirir o no una IV coarse. nargin==2
                %imin=90-5*(i);%%%ojo si se reejecuta. Asume 50,55,70,75 i=1:4.
                IbiasCoarseValues=[500:-1:0];
                mkdir IVcoarse
                cd IVcoarse
                try  %%%A veces dan error las IVs. pq?
                    IVaux=acquire_Pos_Neg_Ivs(Tstring,IbiasCoarseValues);
                catch
                    instrreset;
                    IVaux=acquire_Pos_Neg_Ivs(Tstring,IbiasCoarseValues);
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
            rpp=[0.9:-0.02:0.08];
%             if temps(i)==0.050 %%% || temps(i)==0.07 
%                 rpp=[0.21:-0.01:0.01];
%             end
            rpn=[0.90:-0.02:0.08];
            %rpn=rpp;
            IZvaluesP=BuildIbiasFromRp(IVsetP,rpp);
            IZvaluesN=BuildIbiasFromRp(IVsetN,rpn);
            try
                hp_auto_acq_POS_NEG(IZvaluesP,IZvaluesN);%%%ojo, se sube un nivel
                cd(Tstring)
                pxi_auto_acq_POS_NEG(IZvaluesP,IZvaluesN);%%%se sube tb un nivel
            catch
                cd(basedir)%%%!!! da error al poner cd basedir.
            end
            %cd .. %%%(en acq Z(w) se sube ya un nivel.)
        end
    DONEstr=strcat('T',Tstring,'.end')  
    cd tmp
    f = fopen(DONEstr, 'w' );  
    fclose(f);
    cd ..
end



%%%%Versión cero con fichero de intercambio
% fid=fopen(file,'rt+')
% 
% while (~feof(fid))
%     ftell(fid)%
%     s=fgetl(fid)
%     Temp=sscanf(s,'%f')
%     Tstring=sprintf('%dmK',Temp*1e3)
%     setbool=isempty(strfind(s,'SET'))
%     while setbool
%         %%%bucle de espera al SET temperature.
%         
%     end
%     if strfind(s,'SET')
%         mkdir IVs
%         cd IVs
%         %%%acquireIVs. Automatizar definición de los IbiasValues.
%         %%%Ibias.Ib130=[500:-20:240 235:-5:135 134:-0.5:90 80:-20:0]
%         %%%acquire_Pos_Neg_Ivs('130mK',Ibias.Ib130)
%         cd ..
%         mkdir Z(w)-Ruido
%         cd Z(w)-Ruido
%         mkdir(Tstring)
%         %%%acquire Z(w). Automatizar definición de los IZvalues
%         %%%IZvalues.i135=BuildIbiasFromRp(IVset(18),[0.9:-0.1:0.1])
%         %%%hp_auto_acq_POS_NEG(IZvalues.i135)
%         cd ..
%         %fprintf(fid,'%s','DONE')
%     end
% end
% 
% fclose(fid)