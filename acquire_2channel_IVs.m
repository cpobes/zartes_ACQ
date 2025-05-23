function IV=acquire_2channel_IVs(Temp,Ibias,varargin)
%%%wrapper function to acquire both channels at once. The use of FanInOut
%%%is mandatory in this case.

if nargin==2
%%%default opts.
    opt.sourceCH=1;
    opt.boolplot=1;%%%si queremos o no pintar la curva.
    opt.Rf=10e3;%%%Rf
    opt.averages=5;
    %%%%Fuente a usar: LNCS. Normal
    opt.sourceType='Normal';%%% o 'Normal'.
    opt.softpolarity=1;
    opt.useFanInOut=1;
    opt.OutputDir='.\';
    opt.Ibobina=0;
    optch1=opt;
    optch2=opt;
    optch2.sourceCH=2;
elseif nargin==3
    optch1=varargin{1};
    optch2=optch1;
    optch2.sourceCH=2;
    optch2.OutputDir=strrep(optch1.OutputDir,'1','2');
elseif nargin==4
    optch1=varargin{1};
    optch2=varargin{2};
end
for i=1:2
    opt=eval(strcat('optch',num2str(i)));
    IV(i).ivp=acquireIVs(Temp,Ibias,opt);
    IV(i).ivn=acquireIVs(Temp,-Ibias,opt);
end