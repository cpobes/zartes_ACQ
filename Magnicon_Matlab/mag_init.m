function s=mag_init(varargin)
%Funcion para inicializar la comunicacion con la electronica magnicon.
if nargin == 0
    COM='COM5';
else
    COM=varargin{1};
end

%COM='COM5';%puerto serie.
s=instrfind('type','serial','Port',COM);
%s=[];

% if isempty(s)    
%     s=serial(COM);
%     fopen(s);
% elseif strcmp(s(1).Status,'close')
%     s=s(1);
% end

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

            
%port configuration
set(s,'baudrate',57600,'databits',7,'parity','even','timeout',2,'terminator',{'CR','CR'});


