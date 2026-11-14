function Tinf=lakeshore_control_Tinf(Tset,Plks,Imax)
R_ohm=120;
%P_LKS=100;I_max=1e-3;
k_cte=45e-3;
P_min=25e-6;
a=@(plks,imax)R_ohm*(plks.*imax).^2-k_cte;
b=@(tset,plks,imax) -2*R_ohm*Tset*(plks.*imax).^2;
c=@(tset,plks,imax) R_ohm*(plks.*tset.*imax).^2+P_min;

tinf=@(tset,plks,imax) (-b(tset,plks,imax)-sqrt(b(tset,plks,imax).^2-4*a(plks,imax).*c(tset,plks,imax)))./(2*a(plks,imax));
Tinf=tinf(Tset,Plks,Imax);
