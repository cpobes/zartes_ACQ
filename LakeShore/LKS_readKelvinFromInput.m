function K=LKS_readKelvinFromInput(lks,input)
%%%Devuelve el valor de temperatura en Kelvin para un input. Debe tener
%%%asignada una curva calibrada. Si no, puede dar K=0.
if ~any(strcmp(input,{'A' 'B' 'C' 'D'}))
    error('Wrong input selected')
end

str=strcat('KRDG?',[' ' input]);
K=str2num(query(lks,str));

str=strcat('RDGST?',[' ' input]);
status=query(lks,str);
if str2num(status)>0
    error(strcat('Error de lectura con código ',[' ' status]))
end
