function LKS_AssignCurve2Input(lks,input,curve)
%%%%Asigna una curva determinada a un input.

if ~any(strcmp(input,{'A' 'B' 'C' 'D'}))
    error('Wrong input selected')
end
if curve<21 || curve>59
    error('Wrong Curve number')
end
str=strcat('INCRV',[' ' input],',',num2str(curve));
fprintf(lks,str);

str2=strcat('INCRV?',[' ' input]);
setcurve=str2num(query(lks,str2))%%%NOTA: al intentar asignar la curva25 a 'A', este comando devuelve correctamente '25', 
%%%pero en realidad no se ha asignado bien la curva. Se ve en el display y
%%%si se hace >>query(lks,str2) en la línea de comandos. PQ?
%
if setcurve~=curve
    error('Curve not properly assigned')
end