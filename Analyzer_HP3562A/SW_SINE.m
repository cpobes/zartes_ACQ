function [SW_Data] = SW_SINE (Start_freq, Stop_freq, Resolution, Amplitude, Range)
%%%%Versión del SICE para configurar Sine wave en el HP.

gpib_dev = gpib('ni',0,11);

fopen(gpib_dev);

fprintf(gpib_dev,'ESWQ');
pause(0.5);

fprintf(gpib_dev,'FRSW');
pause(0.5);

% FRS = strcat('FRS',{' '},num2str(Start_freq),',',num2str(Stop_freq),'HZ');
% FRS = FRS{1};
% fprintf(gpib_dev,'%s',FRS);
% pause(0.5);

SF = strcat('SF',{' '},num2str(Start_freq),'HZ');
fprintf(gpib_dev,SF);
pause(0.5);

SPF = strcat('SPF',{' '},num2str(Stop_freq),'HZ');
fprintf(gpib_dev,SPF);
pause(0.5);

RES = strcat('RES',{' '},num2str(Resolution),'P/DC');
fprintf(gpib_dev,RES);
pause(0.5);

SRLV = strcat('SRLV',{' '},num2str(Amplitude),'V');
fprintf(gpib_dev,SRLV);
pause(0.5);

fprintf(gpib_dev,'SRON');
pause(0.5);

RNG = strcat('RNG',{' '},num2str(Range),'V');
fprintf(gpib_dev,RNG);
pause(0.5);

fprintf(gpib_dev,'STRT');
pause(0.5);

for i=1:1000
    
    fprintf(gpib_dev,'SSWP');
    pause(0.5);
    SW_Data (i,1) = fscanf(gpib_dev);
    pause(0.5);
    
    if(i > 0)
            % Loop finish
    end
    
end

fclose(gpib_dev);
delete gpib_dev;

% Procesamiento de los datos