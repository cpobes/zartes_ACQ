function [PSP] = PWR_SPECTRUM (GPIB_ID)
%%%Versión del SICE para coger PS del HP.
try
    
    gpib_dev = gpib('ni',GPIB_ID,11);
    pause(2);

    fopen(gpib_dev);
    pause(0.5);
    
    Process = 1;
    
catch
    
    warndlg('The device ID is wrong or cannot be opened','Wrong Device Configuration');
    
    PSP(1,1) = 0;
    PSP(1,2) = 0;
    
    Process = 0;
    
end


if (Process == 1)
    
    fprintf(gpib_dev,'DDAS');
    pause(0.5);

    s = 1;
    data = '';

    while(s == 1)
    
        data_new = fscanf(gpib_dev); 
   
        if(strcmp('',data_new) == 1)
       
            s = 0;
       
        else
       
            data = strcat(data,data_new);
       
        end
    
    end

    fprintf(gpib_dev,'SF?');
    pause(0.5);
    Start_Freq = fscanf(gpib_dev);
    pause(0.5);
    Start_Freq = str2double(Start_Freq);

    fprintf(gpib_dev,'FRS?');
    pause(0.5);
    Spam_Freq = fscanf(gpib_dev);
    pause(0.5);
    Spam_Freq = str2double(Spam_Freq);

    fprintf(gpib_dev,'LCL');
    pause(0.5);

    fclose(gpib_dev);
    delete (gpib_dev);
    
    Results_Header = fopen('C:\SICE_Programs\Analyzer_3562A\Results_Header.txt','w');
    fprintf(Results_Header,'%s',data);
    fclose(Results_Header);
    
    data = data (1,1024:length(data));

    h = 1;
    PWR_min = 1e15;

    while (length(data) >= 13)
    
        if (strcmp(data(1,1),'+') == 1)
        
            PWR_Data(1,h) = str2double(data(1,1:13));
        
            if(PWR_Data(1,h) <= PWR_min)
            
                if(PWR_Data(1,h) > 0)
                
                    PWR_min = PWR_Data(1,h);
                
                end
            
            end
        
            data = data (1,14:length(data));
    
            h = h + 1;
    
        else
        
            data = data (1,2:length(data));
    
        end
    
    end 

    delta_Freq = Spam_Freq / (length(PWR_Data)-1);

    Freq_vector = logspace(log10(Start_Freq),log10(Start_Freq)+Spam_Freq,length(PWR_Data));
    
    for h=1:length(PWR_Data)
      
        PSP(h,1) = Freq_vector(1,h);
        %PSP(h,1) = Start_Freq + (h-1) * delta_Freq;
        
        PSP(h,2) = PWR_Data(1,h);
    
        if (PSP(h,2) == 0)
        
            PSP(h,2) = PWR_min;
        
        end
    
    end

end







