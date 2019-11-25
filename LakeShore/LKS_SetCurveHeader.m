function str=LKS_SetCurveHeader(lks,curveHDR)
%%%Función para poner el header de una curva. Pasar curva como structura.
%%%ver manual p143.

curve=curveHDR.curve;%%%% ID de la curva 21-59
name=curveHDR.name;%%%nombre para la curva
serial=curveHDR.serial;%%%%numero de serie. Set to zero
format=curveHDR.format;%%%1:mV/K,2:V/K,3:Ohm/K,4:logOhm/K.
limit=curveHDR.limit;%%%limite en temperatura
coeff=curveHDR.coeff;%%%1:neg,2:Pos

str=strcat('CRVHDR ',[' ' num2str(curve)],',',name,',',num2str(serial),',',num2str(format),',',num2str(limit),',',num2str(coeff),'\n')
query(lks,str);