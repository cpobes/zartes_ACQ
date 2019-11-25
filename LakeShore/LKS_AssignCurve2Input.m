function LKS_AssignCurve2Input(lks,input,curve)
%%%%Asigna una curva determinada a un input.

if ~any(strcmp(input,{'A' 'B' 'C' 'D'}))
    error('Wrong input selected')
end
if curve<21 || curve>59
    error('Wrong Curve number')
end
str=strcat('INCRV',[' ' input],',',num2str(curve));
query(lks,str)

str2=strcat('INCRV?',[' ' input]);
str2num(query(lks,str2))
if str2num(query(lks,str2))~=curve
    error('Curve not properly assigned')
end