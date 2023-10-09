function t=BFmanualControlTimer(Tset,pid)
   %myVar = [];
   myVar=BFgetNextManualPower();
   myVar.Tset=Tset;
   Hconfig=BFgetHeaterConfig();
   if Hconfig.pid_mode
       fprintf(2,'BF in PID mode. Set to manual\n');
       t=0;
       return;
   end
   Hconfig.setpoint=Tset;
   Hconfig.control_algorithm_settings=pid;
   BFconfigure(Hconfig);
   t=timer;
   %t.StartFcn = @initTimer;
   t.TimerFcn = @timerCallback;
   t.Period   = 5;
   %t.TasksToExecute = 5;
   t.ExecutionMode  = 'fixedRate';
   start(t);
   %wait(t);
   %delete(t);
   %SOFTPOWERLIMIT=5e-3;%pongo un limite maximo de potencia, que puede ser limitado mas aun en la propia configuracion.
   %MAXPOWER=min(Hconfig.max_power,SOFTPOWERLIMIT);
   function initTimer(src, event)
%         myVar = 0;
%         [T,info]=BFreadMCTemp();
%         myVar.T=T;
%         myVar.E=0;
%         myVar.DE=0;
%         Wlast=last.W;%Winicial?
%         myVar.timestamp=info.timestamp;
%         myVar.Tset=Tset;
        myVar=BFgetNextManualPower();
        myVar.Tset=Tset;
        disp(myVar)
        disp('initialised')
    end
 
   function timerCallback(src, event)
       %myVar = myVar + 1;
       %disp(myVar),pause(1)
       Hconfig=BFgetHeaterConfig();
       ActualPID=Hconfig.control_algorithm_settings;
       myVar = BFgetNextManualPower(myVar,ActualPID);
       %disp(myVar)
       Hconfig.power=max(myVar.W,0); %forzamos valores >=0
       %Hconfig.power=min(myVar.W,MAXPOWER); % ponemos un control de
       %seguridad en la potencia maxima. Al estar en control manual, el
       %max_power de la config no actua por defecto. Lo comento porque
       %aqui da error. Lo paso a BFgetNextManualPower. Tiene tb mas sentido alli. 
       %%%pid:(0.05,200,0) en control manual resulta inestable.
       %%%pid:(0.05,100,0) tb da algunos problemas. En algún momento la W
       %%%se queda fija aunque la T sea diferente a la Tset. Parece estar
       %%%asociado a valores de W negativos.
       BFconfigure(Hconfig);
    end
end