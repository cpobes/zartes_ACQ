function [state,varargout]=Check_TES_State_CH(mag,nch,varargin)
%%%Funcion para comprobar el estado del TES. En varargin paso polarity por
%%%si está invertida. Uso 10*step porque el step es demasiado fino y
%%%fluctua la estimacion de la pendiente. Chequeo también la transicion
%%%cuando S<0.
%%%%la pendiente crítica es más o menos '1'. Para estado superconductor 
%%%%tenemos mS=8000 para Rf=3K -> ms'=2.67. y mN=900 tb para Rf=3K por lo
%%%%que mN'=0.3. Podemos usar por tanto mcritica=1 como criterio.

stack=dbstack('-completenames');%used later.
if nargin==3
    polarity=varargin{1};
else
    polarity=1;
end

multi=multi_init(0);
step=0.06125;%step de la fte normal.
Nsteps=100;
%DeltaI=10*3.05;%%Delta de corriente en la fuente LNCS.
DeltaI=Nsteps*step;%10*1.7;%?!%Delta de corriente en la fte normal en uA.
%mS=8/3;%%%Slope en estado superconductor/3K
%mN=0.3;%%Slope en estado normal.
Rf=mag_readRf_FLL_CH(mag,nch);
%Iaux1=mag_readLNCSImag(mag);
Iaux1=mag_readImag_CH(mag,nch);
Vaux1=multi_read(multi);
%mag_setLNCSImag(mag,Iaux1+DeltaI);
if abs(Iaux1)>abs(500-DeltaI)
    signo=-1;
else
    signo=1;
end
mag_setImag_CH(mag,sign(Iaux1)*(abs(Iaux1)+signo*DeltaI),nch);%%%Ojo a la polaridad de Iaux1.
pause(0.5);
%Iaux2=mag_readLNCSImag(mag);
Iaux2=mag_readImag_CH(mag,nch);
Vaux2=multi_read(multi);
Slope=polarity*(Vaux2-Vaux1)/((Iaux2-Iaux1)*1e-6)/Rf;
%mag_setLNCSImag(mag,Iaux1);%devolvemos al estado inicial.
mag_setImag_CH(mag,Iaux1,nch);%devolvemos al estado inicial.

%fclose(multi);%%%OJO! Necesito multi para calcular la slope, pero
%normalmente uso esta funcion dentro de la acq y si cierro el instrumento,
%luego da error porque otras funciones tratar de usarlo!
if numel(stack) >= 2
   %fprintf('Caller is %s line %d in file %s.\n', stack(2).name, stack(2).line, stack(2).file)
else
   %fprintf('No caller.\n')
   %when no caller, it is called from command line, so close the multi.
   fclose(multi);
end

%Slope
if Slope>1
    state='S';
elseif Slope>0 && Slope<1
    state='N';
elseif Slope<0
    state='T';
end
varargout{1}=Slope;
    