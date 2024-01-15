function fanout_set(fan,c)
%set channel by command:
%b:UP-LEFT, B: UP-RIGHT, a:BOTTOM-LEFT, A:BOTTOM_RIGHT

if sum(strcmp(c,{'a' 'A' 'b' 'B'}))
    fwrite(fan,c);
else
    error('Comando no valido');
end