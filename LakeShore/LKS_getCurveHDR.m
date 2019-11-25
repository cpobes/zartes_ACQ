function curveHDR=LKS_getCurveHDR(lks,curve)
%%%%Función que devuelve el header de una curva deerminada

str=strcat('CRVHDR? ',num2str(curve),'\n')
curveHDR=query(lks,str);