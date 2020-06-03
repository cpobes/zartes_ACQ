function ICpairs=Barrido_fino_Ic_B(Bvalues,varargin)
%%%Barrido Bfield Fino a 80mK
k220=k220_init(0);
mag=mag_init();
nCH=2;%%%Canal de la fuente externa a usar.

%B=[830:5:900 902:2:1300 1305:5:1400]*1e-6;
%B=[1070:10:1400]*1e-6;
B=Bvalues;%%%Realmente son valores de corriente en la bobina.
% step=0.5; %%% El step para medir la Ic
% ICvalues=[0:step:200];

k220_setI(k220,B(1));
k220_Start(k220);
mag_LoopResetCH(mag,nCH);

if nargin==2
    step=varargin{1};
else
    step=0.2;
end

for i=1:length(B)
    B(i)
    k220_setI(k220,B(i));
    pause(1);
    %str=strcat('80mK_',num2str(B(i)*1e6),'uA');
    %measure_Pos_Neg_Ic(str,ICvalues);
    if i<4
        i0=[1 1];
    else
        mmp=(ICpairs(i-1).p-ICpairs(i-3).p)/(B(i-1)-B(i-3));
        mmn=(ICpairs(i-1).n-ICpairs(i-3).n)/(B(i-1)-B(i-3));
        icnext_p=min(500,ICpairs(i-1).p+mmp*(B(i)-B(i-1)));
        icnext_n=max(-500,ICpairs(i-1).n+mmn*(B(i)-B(i-1)));
        ic0_p=max(step,0.9*icnext_p);%%%Por si sale negativo
        ic0_n=min(-step,0.9*icnext_n);
        tempvalues=[0:step:500];%%%array de barrido en corriente
        ind_p=find(tempvalues<=abs(ic0_p));
        ind_n=find(tempvalues<=abs(ic0_n));
        i0=[ind_p(end) ind_n(end)];%%%Calculamos el índice que corresponde a la corriente para empezar el barrido
    end
    try 
        aux=measure_IC_Pair(step,i0);
        %if aux.p==0 aux=measure_IC_Pair(step,floor(0.7*i0));end
        %%%%parche.Funciona si sale Ic=0 un punto a mitad de razado, pero
        %%%%crea artefacto en los primeros ptos pq Ic=0 de forma genuina
        %%%%pero se fuerza a repetir.
        ICpairs(i).p=aux.p;
        ICpairs(i).n=aux.n;
        ICpairs(i).B=B(i);
        step=max(varargin{1},aux.p/20);%por si es cero. Cogemos el máximo entre el step inicial o el 5% de la Icritica.
    catch
        warning('error de lectura')
        pause(1)
        ICpairs(i).p=nan;ICpairs(i).n=nan;
        ICpairs(i).B=B(i);
        %continue;
    end
        save('ICpairs','ICpairs');
        plot(B(1:i),[ICpairs.p],'o-',B(1:i),[ICpairs.n],'o-'),hold off;grid on;
end
k220_setI(k220,0e-6);%%%%
fclose(mag)
fclose(k220)

%%%Truco para que mande el dilución a Tbase si antes se ha lanzado el
%%%programa de LabView adecuadamente.
%     DONEstr=strcat('T','80.0mK','.end')  
%     cd tmp
%     f = fopen(DONEstr, 'w' );  
%     fclose(f);
%     cd ..