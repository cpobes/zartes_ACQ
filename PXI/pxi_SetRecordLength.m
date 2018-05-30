function pxi_SetRecordLength(pxi,RL)
%%%función para fijar el numero de muestras en la adquisicion.

set(get(pxi,'horizontal'),'min_number_of_points',RL)
actualRL=get(get(pxi,'horizontal'),'actual_record_length')

if actualRL~=RL
    warning(strcat('Ojo: Actual Record Length fijado en:',num2str(actualRL)));
    %%%Ojo, este warning parece que no funciona. Si meto RL=333333, en el
    %%%SFP aparece 300000 en rojo para el Record Length, pero al leer el
    %%%campo actual_record_length sique dando 333333. ¿Como leerlo correctamente?
end