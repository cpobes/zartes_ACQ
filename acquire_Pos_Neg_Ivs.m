function IV=acquire_Pos_Neg_Ivs(Temp,Ibias)
%%%wrapper function to acquire both polarities at once.
IV.ivp=acquireIVs(Temp,Ibias);
IV.ivn=acquireIVs(Temp,-Ibias);
% figure,plot([IV.ivn.ibias; IV.ivp.ibias],[IV.ivn.vout; IV.ivp.vout])
