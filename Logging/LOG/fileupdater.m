fileID1 = fopen('IGH-log-full','r');
fileID2 = fopen('IGH-log-temp','a+');
fseek(fileID2,0,'eof');%eof
ind1=ftell(fileID2);
%if(ind1==0)return;end
fseek(fileID1,ind1,'bof');%!
%AData = fread(fileID1);
line=fgetl(fileID1);
fprintf(fileID2,'%s\r\n',line);
fclose(fileID1);
fclose(fileID2);

% for i = 1:1000 
%     fileupdater();
% end