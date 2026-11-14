function Tinf=BF_control_Tinf(Tset,Pbf)
%%%
Tbf=@(tset,P)(sqrt(P^2+196e-3*(P*tset+5e-6))-P)/98e-3;
Tinf=Tbf(Tset,Pbf);