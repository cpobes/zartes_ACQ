function ICpairs=Barrido_Fino_Ic_B(Bvalues)
%%%Barrido Bfield Fino a 80mK
k220=k220_init();
%B=[830:5:900 902:2:1300 1305:5:1400]*1e-6;
%B=[1070:10:1400]*1e-6;
B=Bvalues;
% step=0.5; %%% El step para medir la Ic
% ICvalues=[0:step:200];

k220_setI(k220,B(1));

for i=1:length(B)
    B(i)
    k220_setI(k220,B(i));
    pause(1);
    %str=strcat('80mK_',num2str(B(i)*1e6),'uA');
    %measure_Pos_Neg_Ic(str,ICvalues);
    try 
        aux=measure_IC_Pair();
        ICpairs(i).p=aux.p;
        ICpairs(i).n=aux.n;
        ICpairs(i).B=B(i);
    catch
        warning('error de lectura')
        ICpairs(i).p=nan;ICpairs(i).n=nan;
        ICpairs(i).B=B(i);
        %continue;
    end
        save('ICpairs','ICpairs');
        plot(B(1:i),[ICpairs.p],'o-',B(1:i),[ICpairs.n],'o-'),hold off;
end
k220_setI(k220,1000e-6);

%%%Truco para que mande el dilución a Tbase si antes se ha lanzado el
%%%programa de LabView adecuadamente.
%     DONEstr=strcat('T','80.0mK','.end')  
%     cd tmp
%     f = fopen(DONEstr, 'w' );  
%     fclose(f);
%     cd ..