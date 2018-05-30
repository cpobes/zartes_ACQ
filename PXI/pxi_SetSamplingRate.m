function actualSR=pxi_SetSamplingRate(pxi,SR)
%%%Función para cambiar el sampling rate

set(get(pxi,'horizontal'),'min_sample_rate',SR)
actualSR=get(get(pxi,'horizontal'),'Actual_Sample_Rate');

if actualSR~=SR
    warning(strcat('Ojo: Sampling Rate fijado en:',num2str(actualSR)));
end