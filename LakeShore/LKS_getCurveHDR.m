function curveHDR=LKS_getCurveHDR(lks,curve)
%%%%Funci�n que devuelve el header de una curva deerminada

str=strcat('CRVHDR? ',num2str(curve),'\n')
curveHDR=query(lks,str);