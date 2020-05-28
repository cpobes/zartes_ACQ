function curvePoint=LKS_getCurvePoint(lks,curve,point)
%%%%Función que devuelve el punto de una curva determinada.

str=strcat('CRVPT? ',num2str(curve),',',num2str(point),'\n')
curvePoint=query(lks,str);