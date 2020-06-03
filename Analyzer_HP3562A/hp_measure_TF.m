function datos=hp_measure_TF(dsa,varargin)
%%funcion para medir una TF.
%hp_ss_config(dsa);
    
    if nargin==2
        V=round(varargin{1}*1e4*1e3);%%%Expresado en mV
        str=strcat('SRLV ',' ',num2str(V),'mV')%%amplitud de excitación*10
    else
        str=strcat('SRLV 50mV');
    end
    
    fprintf(dsa,str);
    fprintf(dsa,'STRT');%Lanza la medida
    fprintf(dsa,'SMSD');%query measure finish?
    ready=str2double(fscanf(dsa));
    %bucle de espera de la medida.
    while(~ready)
        pause(5);
        fprintf(dsa,'SMSD');
        ready=str2double(fscanf(dsa));
        second(now)
    end
    
    [freq,data]=hp_read(dsa);%lee la TF.
    datos=[freq' data'];