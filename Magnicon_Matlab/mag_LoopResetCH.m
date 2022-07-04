function mag_LoopResetCH(mag,sourceCH)
%%%%Resetea el lazo de un canal.
%mag_setAMP_CH(mag,sourceCH);
%mag_setFLL_CH(mag,sourceCH);
%%%desde que tenemos 2 canales, es importante resetear siempre los dos
mag_setAMP_CH(mag,1);
mag_setFLL_CH(mag,1);
mag_setAMP_CH(mag,2);
mag_setFLL_CH(mag,2);