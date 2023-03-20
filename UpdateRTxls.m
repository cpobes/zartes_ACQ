function UpdateRTxls(file,data)
%%%funcion para volcar data en la excel de RTs
%%%formato data.RTs.CHn.{name,size}
x=fieldnames(data.RTs);
for i=1:6
    name={data.RTs.(x{i}).name};
    size={data.RTs.(x{i}).size};
    xlswrite(file,name,1,strcat('B',num2str(i+1)));
    if ~isempty(size) xlswrite(file,size,1,strcat('C',num2str(i+1)));end
end