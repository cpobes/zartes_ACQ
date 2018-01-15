function datos=hp_measure_TF(dsa)
%%funcion para medir una TF.
hp_ss_config(dsa);

    fprintf(dsa,'STRT');%Lanza la medida
    fprintf(dsa,'SMSD');%query measure finish?
    ready=str2double(fscanf(dsa));
    %bucle de espera de la medida.
    while(~ready)
        pause(10);
        fprintf(dsa,'SMSD');
        ready=str2double(fscanf(dsa));
        second(now)
    end
    
    [freq,data]=hp_read(dsa);%lee la TF.
    datos=[freq' data'];