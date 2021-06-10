function datos=hp_measure_TF(dsa,varargin)
%%funcion para medir una TF.

    x=query(dsa,'AVG?');%%%Uso el AVG como identificador de si está en modo TF o modo noise.
    %%%% En modo TF sólo hay 1 average, mientras que en modo noise lo tengo
    %%%% en avg=5 (ojo, esto puede cambiar, no es robusto). De esta forma
    %%%% puedo hacer que si quiero medir de golpe las TF o no medir noise,
    %%%% sólo configura la primera vez, y el resto no tiene que
    %%%% reconfigurar. Lo mismo para el noise.

    if(x==5) hp_ss_config(dsa);end
    
    if nargin==2
        V=round(abs(varargin{1}*1e4*1e3));%%%Expresado en mV
        str=strcat('SRLV ',' ',num2str(V),'mV')%%amplitud de excitación*10
    else
        str=strcat('SRLV 20mV');
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