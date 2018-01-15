function out=checkDirb4Acq()
%%checkea el directorio actual. Si no estás en un directorio con 'TmK' en
%%el nombre o el directorio contiene ficheros con numeros, devuelve un '1'
%%para abortar la acq.
d=pwd;
nodir=isempty(regexp(d,'\d*mK','match'));

f=ls;
[i,j]=size(f);
fc=mat2cell(f,ones(1,i),j);
emptydir=prod(double(cellfun('isempty',regexp(fc,'\d+','match'))));

out=nodir|~emptydir;