function mag_Configure_CalPulse(mag)
%%%Configura la fuente de pulsos para adquirir automaticamente
%delta T:100ms-1seg
%duracion maxima:2000us
%modo:cont
%Amplitud: 20uA?
AMP=20;%%%Amplitud en uA.
mag_setCalPulseAMP_CH(mag,0,AMP,2);%%% handle, RL,AMP(uA),CH.
mag_setCalPulseDT_CH(mag,1000,2);%%% handle, separacion(ms), CH.%%%%!
mag_setCalPulseDuration_CH(mag,2000,2); %%%handle, duracion(us), CH
mag_setCalPulseMode_CH(mag,'continuous',2);
%mag_setCalPulseMode_CH(mag,'single',2);