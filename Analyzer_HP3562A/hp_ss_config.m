function hp_ss_config(dsa)
%% Configuración del HP para medir una Funcion de Transferencia con Sine Sweept
fprintf(dsa,'AUTO 0')

fprintf(dsa,'SSIN')
fprintf(dsa,'LGSW')
fprintf(dsa,'RES 20P/DC');%%%He usado normalmente 5P/DC
fprintf(dsa,'SF 1Hz')
fprintf(dsa,'FRS 5Dec')
fprintf(dsa,'SWUP') %%%puede quedar en manual sweep y entonces no sube la frecuencia.
fprintf(dsa,'SRLV 100mV')%%amplitud de excitación*10
fprintf(dsa,'C2AC 0') %CH2 coupling DC.
%fprintf(dsa,'C2AC 1') %CH2 coupling AC.
fprintf(dsa,'FRQR')
fprintf(dsa,'VTRM')
fprintf(dsa,'VHZ')
fprintf(dsa,'NYQT')

%fprintf(dsa,'STRT')
