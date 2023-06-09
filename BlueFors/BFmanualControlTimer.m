function t=BFmanualControlTimer(Tset,pid)
   %myVar = [];
   myVar=BFgetNextManualPower();
   myVar.Tset=Tset;
   Hconfig=BFgetHeaterConfig();
   Hconfig.setpoint=Tset;
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
       myVar = BFgetNextManualPower(myVar,pid);
       %disp(myVar)
       Hconfig=BFgetHeaterConfig();
       Hconfig.power=myVar.W;
       %%%pid:(0.05,200,0) en control manual resulta inestable.
       BFconfigure(Hconfig);
    end
end