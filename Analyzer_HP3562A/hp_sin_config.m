function hp_sin_config(dsa,freq,varargin)
%%%función para configurar la source del HP.
%%%v2: configuramos todo solo en la primera llamada, y luego solo la
%%%frecuencia.

if nargin==2
%fprintf(dsa,'MNSW');
fprintf(dsa,'LGRS'); %%%%Para poder usar Fixed Sine hay que estar en modo Log
str=strcat('FSIN',char(32),num2str(freq),'HZ')
fprintf(dsa,str)
fprintf(dsa,'SRLV 40mV')%%amplitud de excitación*10. Def:40mV
else
    str=strcat('FSIN',char(32),num2str(freq),'HZ')
    fprintf(dsa,str)
end