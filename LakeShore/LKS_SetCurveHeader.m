function str=LKS_SetCurveHeader(lks,curveHDR)
%%%Función para poner el header de una curva. Pasar curva como structura.
%%%ver manual p143.

curve=curveHDR.curve;
name=curveHDR.name;
serial=curveHDR.serial;
format=curveHDR.format;
limit=curveHDR.limit;
coeff=curveHDR.coeff;

str=strcat('CRVHDR ',[' ' num2str(curve)],',',name,',',num2str(serial),',',num2str(format),',',num2str(limit),',',num2str(coeff),'\n')
query(lks,str);