function Vdc=multi_read(multi)

%out=query(multi,'');
fprintf(multi,'TRIG SGL');
out=fscanf(multi);
Vdc=str2num(out); %#ok<ST2NM>