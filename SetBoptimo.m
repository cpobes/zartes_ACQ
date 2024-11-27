function realIbob=SetBoptimo(Ibob)
%%%funcion para poner una cierta corriente en la bobina. 
%%%%K220
bool_LNCS=1;
bool_k220=0;%%%new version uses LNCS.
if bool_k220
    k220=k220_init(0);
    k220_setVlimit(k220,5);
    try
        k220_Start(k220);
    catch
        k220_Start(k220);
    end

    try
        k220_setI(k220,Ibob);
    catch
        try 
            k220_Stop(k220);
            k220_Start(k220);
        catch
            k220_Stop(k220);
            k220_Start(k220);
        end
        k220_setI(k220,Ibob);    
    end
    realIbob=k220_readI(k220);
    fclose(k220);
end
if bool_LNCS
    mag=mag_init();
    mag_ConnectLNCS(mag);
    mag_setLNCSImag(mag,Ibob);
    realIbob=mag_readLNCSImag(mag);
end