function hp_sin_config(dsa,freq)
%%%función para configurar la source del HP.


%fprintf(dsa,'MNSW');
fprintf(dsa,'LGRS'); %%%%Para poder usar Fixed Sine hay que estar en modo Log
str=strcat('FSIN',char(32),num2str(freq),'HZ')
fprintf(dsa,str)
fprintf(dsa,'SRLV 40mV')%%amplitud de excitación*10. Def:40mV