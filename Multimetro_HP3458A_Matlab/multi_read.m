function Vdc=multi_read(multi)

out=query(multi,'');
Vdc=str2num(out); %#ok<ST2NM>