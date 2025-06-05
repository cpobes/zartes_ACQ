function Current=LKS_readHeaterCurrent(lks,output)
%%%%Función para devolver la corriente de excitacion a partir del
%%%%porcentaje.
%%%output2 limits. pag34 manual. For 120ohm, limita voltaje Pmax=0.83W.
%%%Asi que ojo porque la Imax que va a dar son 83mA en lugar de 100mA. 
%%%(esto puede ser relevante en Rango5).
%%% Output2 rangos. pag53 manual:
%   Rango5: 100mA
%   Rango4: 31.6mA
%   Rango3: 10mA
%   Rango2: 3.16mA
%   Rango1: 1mA.


if output>=1 && output<=4
    if output~=2
        error('Funcion aplicable solo a Output 2');
    end
else
    error('wrong output number');
end

str=strcat('htr? ',num2str(output),'\n');
HtrPerc=str2num(query(lks,str));
HtrRng=LKS_getHeaterRange(lks,output);
aux=strsplit(query(lks,'HTRSET? 2'),',');%output2
%aux{end}
HtrSet=str2num(aux{end});
if HtrSet==2
    HtrPerc=10*sqrt(HtrPerc);%En modo power hay que convertir a corriente.
end
if output ==2
    switch HtrRng(1)
        case '1'
            Current=HtrPerc*1/100;%1mA
        case '2'
            Current=HtrPerc*3.16/100;%3.16mA
        case '3'
            Current=HtrPerc*10/100;%10mA
        case '4'
            Current=HtrPerc*31.6/100;%31.6mA
        case '5'
            Current=HtrPerc;%100mA
        case '0'
            disp('Output OFF');
    end
end