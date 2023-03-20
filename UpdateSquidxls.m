function UpdateSquidxls(file, data)
%%%Funcion para volcar data en file. Version naive.
%formato data.SQUIDs.(CHn).(name) Para pasar mas info hay que cambiar
%Init_Template.json
fecha={date};
if ~isempty(strfind(file,'CH1'))
    name={data.SQUIDs.CH1.name};
    size={data.SQUIDs.CH1.size};
    xlswrite(file,name,1,'C2');
    xlswrite(file,fecha,1,'D2');
    xlswrite(file,size,1,'I2');%%El size no está originalmente en el excel. Lo incluimos aqui aunque deberá cargarse desde la BD.
end
if ~isempty(strfind(file,'CH2'))
    name={data.SQUIDs.CH2.name};
    size={data.SQUIDs.CH2.size};
    xlswrite(file,name,1,'C2');
    xlswrite(file,fecha,1,'D2');
    xlswrite(file,size,1,'I2');
end