function rango=multi_monitor(multi)

N=100;
vout=multi_read(multi);
for i=1:N
    vaux(i)=multi_read(multi);
end
rango=range(vaux);
%plot(vaux,'.-')