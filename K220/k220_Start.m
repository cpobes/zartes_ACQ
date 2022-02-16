function k220_Start(k220)
%%%Función para activar el output de la fuente.
str='F1T4X\n';
query(k220,str);
if ~k220_CheckOUTPUT(k220) error('Error activando la fuente');end