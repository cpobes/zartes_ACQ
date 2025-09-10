function fanout_selectCH(ch)
fan=fanout_init();
if ch==0
    c='b';
elseif ch==1
    c='B';
else
    error('Wrong channel number');
end
fwrite(fan,c);
fclose(fan);