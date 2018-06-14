function pxi_ConfigureHorizontal(pxi,conf)
%%%%Funci�n para configurar de golpe toda la escala horizontal.
%%%SR: Sampling Rate en S/Seg, RL: Record Length, n� samples, RefPos: Reference Position for trigger en % (div 2=20.). 

SR=conf.SR;
RL=conf.RL;
RefPos=conf.RefPos;

pxi_SetSamplingRate(pxi,SR);
pxi_SetRecordLength(pxi,RL);
set(get(pxi,'horizontal'),'Reference_Position',RefPos);