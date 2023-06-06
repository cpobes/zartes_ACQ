function BFmanualControlTimer(Tset,pid)
   myVar = [];
   t=timer;
   t.StartFcn = @initTimer;
   t.TimerFcn = @timerCallback;
   t.Period   = 5;
   %t.TasksToExecute = 5;
   t.ExecutionMode  = 'fixedRate';
   start(t);
   %wait(t);
   %delete(t);
   
   function initTimer(src, event)
        myVar = 0;
        [T,info]=BFreadMCTemp();
        myVar.T=T;
        myVar.E=0;
        myVar.DE=0;
        Wlast=last.W;%Winicial?
        myVar.timestamp=info.timestamp;
        myVar.Tset=Tset;
        disp('initialised')
    end
 
   function timerCallback(src, event)
       %myVar = myVar + 1;
       myVar = BFgetNextManualPower(myVar,pid)
       disp(myVar)
    end
end