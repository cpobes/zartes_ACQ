function mag_LoopResetCH(mag,sourceCH,varargin)
%%%%Resetea el lazo de un canal.
mag_setAMP_CH(mag,sourceCH);
mag_setFLL_CH(mag,sourceCH);
%%%desde que tenemos 2 canales, es importante resetear siempre los dos
%mag_setAMP_CH(mag,1);
%mag_setFLL_CH(mag,1);
%mag_setAMP_CH(mag,2);
%mag_setFLL_CH(mag,2);
%nos aseguramos de que el otro canal queda en modo AMP.
if nargin==2
    flag=1;
else
    flag=varargin{1};
end
if flag
    mag_setAMP_CH(mag,mod((-1)^sourceCH,3));
end