function iv=measure_Pos_Neg_Ic(Temp,Ivalues)
%%%wrapper para polaridad pos y neg de las Icriticas
iv.p=measure_Ic(Temp,Ivalues,'.-');
iv.n=measure_Ic(Temp,-Ivalues,'.-r');