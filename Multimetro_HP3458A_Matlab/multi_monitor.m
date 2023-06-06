function rango=multi_monitor(multi,varargin)
%Funcion para monitorizar el Vout durante unas cuantas muestras N
%(default=100). Cuando la medida es estable, rango<0.5mV.
if nargin==1
    N=100;
else
    N=varargin{1};
end
%vout=multi_read(multi);
for i=1:N
    vaux(i)=multi_read(multi);
end
rango=range(vaux);
%plot(vaux,'.-')