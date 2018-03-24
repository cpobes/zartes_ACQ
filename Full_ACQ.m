function Full_ACQ(file,circuit)
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

for i=1:length(temps)

    %SETstr=strcat('tmp\T',num2str(1e3*temps(i)),'mK.stb')
    Tstring=sprintf('%0.1fmK',temps(i)*1e3)
    SETstr=strcat('tmp\T',Tstring,'.stb')
    
    
    while(~exist(SETstr,'file'))
        %bucle para esperar a Tbath SET 
    end


        %%%acquireIVs. Automatizar definición de los IbiasValues.
        %%%Ibias.Ib130=[500:-20:240 235:-5:135 134:-0.5:90 80:-20:0]
        mkdir IVtemp
        cd IVtemp
        
         IbiasValues=[500:-10:300 295:-5:200 198:-2:130 129.5:-0.5:0];%%%!!!!Crear funcion!!!!
         if temps(i)>84
             IbiasValues=[500:-10:50 49:-1:0];
         end
%         if temps(i)<0.072
%             IbiasValues=[500:-20:200 195:-5:150 149.5:-0.5:0]; %%%Debería saltar al detectar el estado S.
%         elseif temps(i)<0.08
%             IbiasValues=[500:-20:200 190:-10:150 148:-2:100 99.5:-0.5:0]; %%%Debería saltar al detectar el estado S.
%         else
%             IbiasValues=[500:-20:100 95:-5:60 59.5:-0.5:0];
%         end
        
         IVaux=acquire_Pos_Neg_Ivs(Tstring,IbiasValues);
        
        cd ..
        %%%Para medir Icriticas
        if(0) %%%temps(i)>0.080
        mkdir ICs
        cd ICs
        Ivalues=[0:0.25:500];
        ic(i)=measure_Pos_Neg_Ic(Tstring,Ivalues);
        cd ..
        end

%%%definimos un array con temperaturas a las que adquirir Z(w)-ruido, que
%%%puede ser un subconjunto de las Tbath a las que se mida IV.
    %auxarray=[0.04 0.045 0.05 0.055 0.06 0.065 0.07 0.075 0.08 0.085 0.09];
    auxarray=[.045 0.060 0.065 0.070 0.075 0.080];
        if(~isempty(find(auxarray==temps(i), 1)))
%             mkdir Z(w)-Ruido
%             cd Z(w)-Ruido

            mkdir(Tstring)
            cd(Tstring)%%%La adquisicion de Z(w) comienza en el directorio de cada Tbath
            %%%y vuelve al superior
            %%%acquire Z(w). Automatizar definición de los IZvalues

            IVsetP=GetIVTES(circuit,IVaux.ivp);%%%nos quedamos con la IV de bias positivo.
            IVsetN=GetIVTES(circuit,IVaux.ivn);

            rp=[0.85:-0.05:0.15]; %%%Vector con los puntos donde tomar Z(w).           
            IZvaluesP=BuildIbiasFromRp(IVsetP,rp);
            IZvaluesN=BuildIbiasFromRp(IVsetN,rp);
            try
                hp_auto_acq_POS_NEG(IZvaluesP,IZvaluesN);
            catch
                cd basedir
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