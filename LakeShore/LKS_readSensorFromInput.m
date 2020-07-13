function R=LKS_readSensorFromInput(lks,input)
%%%DEvuelve la lectura del input en las unidades del sensor (Ohm?)
if ~any(strcmp(input,{'A' 'B' 'C' 'D'}))
    error('Wrong input selected')
end

str=strcat('SRDG?',[' ' input]);
R=str2num(query(lks,str));

str=strcat('RDGST?',[' ' input]);
status=query(lks,str);
if str2num(status)>0
    error(strcat('Error de lectura con código ',[' ' status]))
end