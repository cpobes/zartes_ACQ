function s=mag_init()
%Funcion para inicializar la comunicacion con la electronica magnicon.
COM='com5';%puerto serie.
s=instrfind('type','serial','status','open');

if isempty(s)    
    s=serial(COM);
    fopen(s)
else
    s=s(1);
end

%port configuration
set(s,'baudrate',57600,'databits',7,'parity','even','timeout',2,'terminator',{'CR','CR'});


