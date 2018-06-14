function hp_noise_config(dsa)
%% Configuración del HP para medir ruido del CH2.

fprintf(dsa,'AUTO 0')
%fprintf(dsa,'FRQR')
fprintf(dsa,'LGRS')
fprintf(dsa,'SF 10Hz') %Start Frequency
fprintf(dsa,'FRS 4Dec') %Frequency Span
fprintf(dsa,'PSUN') 
fprintf(dsa,'VTRM')
fprintf(dsa,'VHZ')
fprintf(dsa,'STBL') %stable mean
fprintf(dsa,'AVG 5') %Numero de Averages
fprintf(dsa,'C2AC 1') %CH2 coupling AC.
%fprintf(dsa,'C2AC 0') %CH2 coupling DC.
fprintf(dsa,'PSP2') %power spec 2
fprintf(dsa,'MGDB'); %mag db
fprintf(dsa,'YASC');%Y auto scale
%fprintf(dsa,'SNGC') %Single CAL. Ojo, da timeout.