function IV=acquire_Pos_Neg_Ivs(Temp,Ibias,varargin)
%%%wrapper function to acquire both polarities at once.

if nargin==2
    IV.ivp=acquireIVs(Temp,Ibias);
    IV.ivn=acquireIVs(Temp,-Ibias);
elseif nargin==3
    IV.ivp=acquireIVs(Temp,Ibias,varargin{1});
    IV.ivn=acquireIVs(Temp,-Ibias,varargin{1});
end
% figure,plot([IV.ivn.ibias; IV.ivp.ibias],[IV.ivn.vout; IV.ivp.vout])
