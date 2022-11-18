function datos=hp_measure_noise(dsa)
%%funcion para medir un ruido con el HP.

    x=str2num(query(dsa,'AVG?'));%%%Uso el AVG como identificador de si está en modo TF o modo noise.
    %%%% En modo TF sólo hay 1 average, mientras que en modo noise lo tengo
    %%%% en avg=5 (ojo, esto puede cambiar, no es robusto). De esta forma
    %%%% puedo hacer que si quiero medir de golpe las TF o no medir noise,
    %%%% sólo configura la primera vez, y el resto no tiene que
    %%%% reconfigurar. Lo mismo para el noise.
    
if(x==1) hp_noise_config(dsa);end
    %fprintf(dsa,'SNGC');
    %pause(20);%%%Si lanzamos CAL(SNGC) hay que esperar un poco.

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