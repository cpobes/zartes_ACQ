function [freq,data,header] = hp3562a(varargin)
% 
if nargin == 0
    gpib_dir=1;
else
    gpib_dir=varargin{1};
end

dsa=instrfind('Status','open');
if isempty(dsa)
    
    dsa=gpib('ni',gpib_dir,11);%dir:1 puede cambiar
    fopen(dsa); %cerrar al final.
end
%instrfind; %muestra los instrumentos y su estado.

fprintf(dsa,'ID?');
device=fscanf(dsa)%devuelve HP3562A. Permite comprobar si estamos leyendo el 
if ~strcmpi('HP3562A',device(1:end-2)), return;end %dispositivo correcto?

%%%%%%%%%%%ASCII read header %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(dsa,'DDAS');
fread(dsa,2,'char');%se leen los 2 primeros caracteres. #I
header.n_tot=str2double(char(fread(dsa,15,'char')));%se lee el numero total de entries
header.df=str2double(char(fread(dsa,15,'char')));%se lee la 'display function'
header.n_points=str2double(char(fread(dsa,15,'char'))); % se lee el numero de puntos
%debe ser n_tot-66
header.d_points=str2double(char(fread(dsa,15,'char')));%se lee num diplayed points
header.n_avg=str2double(char(fread(dsa,15,'char'))); % numero de averages
header.ch=str2double(char(fread(dsa,15,'char')));%channels

fread(dsa,15*30,'char');%next 30 entries in header 
%maximum resd_size 512 chars.
str2double(char(fread(dsa,15*5,'char')));%next 5 entries in header
header.loglin=str2double(char(fread(dsa,15,'char')));%log linear boolean
fread(dsa,15*2,'char');
header.measmode=str2double(char(fread(dsa,15,'char')));%modo medida. 0:linear res,1:log res,2:swept sine
fread(dsa,15*11,'char');%next 10 entries in header
header.Dx=str2double(char(fread(dsa,15,'char')));%deltaX. 10Dx si measmod=1.
fread(dsa,15*8,'char');%next 8 entries
header.start_values=fread(dsa,25*2,'char');%last 2 entries.
header.size=66; %%length of header in entries.
header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n_data=(header.n_tot-header.size)/header.n_points; %segun el modo de lectura tenemos un array con los
%datos o dos arrays (real e imag).

%ASCII read data
for i=1:header.n_points,
    %data(j,i)=str2double(char(fread(dsa,15,'char')));
    %los datos se devuelven como un array simple o como parejas (Re, Im).
    data(1,i)=str2double(char(fread(dsa,15,'char')));
    if (n_data==2) data(2,i)=str2double(char(fread(dsa,15,'char'))); end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fprintf(dsa,'SF?');
st_freq=str2double(fscanf(dsa));
fprintf(dsa,'FRS?');
sp_freq=str2double(fscanf(dsa));

if header.loglin==0 %header.measmode==0
    freq=st_freq:header.Dx:st_freq+sp_freq;
elseif header.loglin==1 %header.measmode==1
    %freq=10.^(log10(st_freq):header.Dx:log10(st_freq)+sp_freq); %A veces
    %Dx no es suficientemente preciso y da un size(freq) erroneo.
    freq=logspace(log10(st_freq),log10(st_freq)+sp_freq,header.n_points);
    %header.Dx,size(freq)
    %freq(1),freq(end)
end

%return;
fclose(dsa)
size(freq),size(data)
%data=data(1:end-1);


datos=[freq' data'];
save('tempresults.txt','datos','-ascii');

loglog(freq,data)
grid on