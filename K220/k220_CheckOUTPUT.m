function out=k220_CheckOUTPUT(k220)
%%%%%
x=query(k220,'U0X\n');
out=str2double(x(5));