function curvePoint=LKS_getCurvePoint(lks,curve,point)
%%%%Funci�n que devuelve el punto de una curva determinada.

str=strcat('CRVPT? ',num2str(curve),',',num2str(point),'\n')
curvePoint=query(lks,str);