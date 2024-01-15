function s=fanout_init(varargin)
%Funcion para inicializar la comunicacion con la electronica magnicon.
if nargin == 0
    COM='COM5';%usually COM5.
else
    COM=varargin{1};
end

%COM='COM5';%puerto serie.
s=instrfind('type','serial','Port',COM);

switch length(s)
    case 0
        s=serial(COM);
        fopen(s);
    case 1
        if (strcmp(s.Status,'closed')) fopen(s);end
    otherwise        
        for i=2:length(s) delete(s(i));end
        s=s(1);
        if (strcmp(s.Status,'closed')) fopen(s);end
end