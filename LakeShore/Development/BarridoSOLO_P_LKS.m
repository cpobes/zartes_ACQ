% Acordarse de inicializar el LKS antes de medir -> LKS_init()
% Salida de control: 0 (sample heater). Entrada de control: 'A'.


%comandos utiles
%fprintf(lks, 'HTRSET? 0\n'); disp(fscanf(lks)) devuelve el valor del
%heater
%fprintf(lks, 'RANGE? 0\n');  disp(fscanf(lks)) modo del heater 1 = corriente, 2 = potencia
%fprintf(lks, sprintf('SETP 0,%.6f\n') setpoint LKS
%fprintf(lks, sprintf('PID 0,%g,0,0\n') PID LKS 


%mirar antes en que modo esta el LKS para saber que esta guardando en
%potencia 
%mirar tambien en que rango esta


Pset  = 75;
%TStep = [0.06 0.07 0.08 0.09 0.1 0.11 0.12]; %%LA TEMPERATURA SE PONE EN KELVIN NO mK!!!!!!!!!!
TStep=0.06;
Rhtr  = 120;  Imax = 1e-3;  modo = 1; %datos para intentar sacar la potencia

fprintf(lks, sprintf('PID 0,%g,0,0\n', Pset));
figure(1)
figure(2)
LKS_SetHeaterRange(lks,0,4)
for j = 1:numel(TStep) %corre sobre todas las temperaturas
    fprintf(lks, sprintf('SETP 0,%.6f\n', TStep(j)));
    T = []; pct = []; t = []; t0 = tic;

    while toc(t0) < 1000  %leemos T y P 
        T(end+1)   = LKS_readKelvinFromInput(lks,'A');
        pct(end+1) = LKS_readHeaterPercentage(lks,0);
        t(end+1)   = toc(t0);

        if mod(numel(T), 10) == 0  %ploteamos cada 10 medidas
            %yaxis left;  
            figure(1),plot(t, T*1e3); ylabel('T [mK]')
            %yaxis right; 
            figure(2),plot(t, pct);   ylabel('heater [%]')
            xlabel('t [s]'); title(sprintf('Setpoint %.0f mK', TStep(j)*1e3))
            drawnow
        end

        if numel(T) > 500   %criterio de estabilidad, pendiente + std
            p = polyfit(t(end-99:end), T(end-99:end), 1);
            if std(T(end-99:end)) < 50e-7 && abs(p(1)) < 2e-7, break, end
        end
        pause(0.25)
    end

    Tmed(j)   = mean(T(end-99:end));   %temperatura media
    err(j)    = TStep(j) - Tmed(j);    
    pctMed(j) = mean(pct(end-99:end));  %potencia media
    if modo == 1
        Pw(j) = (Imax*pctMed(j)/100)^2 * Rhtr;  %intento de calcular la potencia
    else
        Pw(j) = pctMed(j)/100 * Imax^2 * Rhtr;
    end

    fprintf('Tset %.0f mK  err %.3f mK  heater %.1f %%  P %.3g W\n', ...
            TStep(j)*1e3, err(j)*1e3, pctMed(j), Pw(j));

    Tset = TStep(j);
    save(sprintf('P%g_T%gmK.mat', Pset, TStep(j)*1e3), ...
         't', 'T', 'pct', 'Tset', 'Pset', 'Rhtr', 'Imax', 'modo')
end

% Restaurar PID conocido y setpoint de trabajo
fprintf(lks, 'PID 0,100,150,0\n');
fprintf(lks, 'SETP 0,0.050\n');

save(sprintf('P%g_resumen.mat', Pset), 'TStep', 'Tmed', 'err', 'pctMed', 'Pw', 'Pset', 'Rhtr', 'Imax', 'modo')

figure
plot(err*1e3, pctMed, 'o'); xlabel('error [mK]'); ylabel('heater [%]')

disp('Barrido acabado')


%si queremos verlo despues del tiron:
%load('P100_T80mK.mat')
%yyaxis left; plot(t, T*1e3); yyaxis right; plot(t, pct)