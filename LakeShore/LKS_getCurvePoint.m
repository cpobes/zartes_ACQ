function curvePoint=LKS_getCurvePoint(lks,curve,point)
%%%%Funci�n que devuelve el header de una curva deerminada

str=strcat('CRVPT? ',num2str(curve),',',num2str(point),'\n')
curvePoint=query(lks,str);