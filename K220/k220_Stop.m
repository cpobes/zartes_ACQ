function k220_Stop(k220)
%%%Funci�n para desactivar el output de la fuente.
str='F0T4X\n'; %%% Funciona tambi�n 'F0T5X\n
query(k220,str);
if k220_CheckOUTPUT(k220) error('error desactivando la fuente');end