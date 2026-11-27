function pxi_ConfigureHorizontal(pxi,conf)
%%%%Función para configurar de golpe toda la escala horizontal.
%%%SR: Sampling Rate en S/Seg, RL: Record Length, nº samples, RefPos: Reference Position for trigger en % (div 2=20.). 

SR=conf.SR;
RL=conf.RL;
RefPos=conf.RefPos;

% pxi_SetSamplingRate(pxi,SR);
% pxi_SetRecordLength(pxi,RL);
% set(get(pxi,'horizontal'),'Reference_Position',RefPos);

%invoke(get(pxi,'horizontal'),'configurehorizontaltiming', SR, RL, RefPos);%, 1, true);

invoke(get(pxi,'Acquisition'), 'abort');
gHor = get(pxi, 'ConfigurationFunctionsHorizontal');
invoke(gHor, 'configurehorizontaltiming', SR, RL, RefPos, 1, 1);   % SR (S/s), RL (muestras), RefPos (%), Nrecords, realtime
gAct = get(pxi, 'ConfigurationFunctionsActualValues');
fs = invoke(gAct, 'samplerate')            % lo que ha aplicado de verdad
rl = invoke(gAct, 'actualrecordlength')