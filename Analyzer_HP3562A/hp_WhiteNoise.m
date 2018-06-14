function hp_WhiteNoise(dsa,AMP)
%%%Activa la fuente con ruido blanco. Pasar Amp en mV

fprintf(dsa,'LGRS');
fprintf(dsa,'RND');
str=strcat('SRLV',char(32),num2str(AMP),'mV')
fprintf(dsa,str)
hp_Source_ON(dsa)