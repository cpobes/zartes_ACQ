function k220_Stop(k220)
%%%Función para desactivar el output de la fuente.
str='F0T4X\n'; %%% Funciona también 'F0T5X\n
query(k220,str);
if k220_CheckOUTPUT(k220) error('error desactivando la fuente');end