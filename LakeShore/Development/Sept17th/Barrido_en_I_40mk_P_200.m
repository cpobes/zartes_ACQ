% Acordarse de inicializar el LKS antes de medir -> LKS_init()
% Salida de control: 0 (sample heater). Entrada de control: 'A'.

%Parametros a definir para el analisis

tMaxEstab=900;

Tset = 0.04;
Dset = 0;
Pset = 200;
%%LA TEMPERATURA SE PONE EN KELVIN NO mK!!!!!!!!!!
Iset=[160, 170, 180, 190, 195, 200];
%Iset=[100, 150];
%fprintf(lks, sprintf('PID 0,%g,%g,%g\n', Pset, Iset, Dset));
fprintf(lks, sprintf('SETP 0,%.6f\n', Tset));
figure('windowstyle','docked')

for j = 1:length(Iset)

    %Setpoint a TStep: registrar desde ya hasta estabilizar (o timeout)
    T_LK = []; x = []; lksPower = [];

   % fprintf(lks, sprintf('SETP 0,%.6f\n', TStep(j)));
    fprintf(lks, sprintf('PID 0,%g,%g,%g\n', Pset, Iset(j), Dset));
    t0 = tic;
    while true
        T_LK(end+1)     = LKS_readKelvinFromInput(lks,'A'); %#ok<*SAGROW>
        lksPower(end+1) = LKS_readHeaterPercentage(lks,0);
        x(end+1)        = now;

        plotyy(x, T_LK, x, lksPower); grid on
        datetick('x',13)
        title(sprintf('Subida y estabilizacion a %.0f mK)', Iset(j)))
        drawnow

       

        if toc(t0) > tMaxEstab
            warning('Iset=%g:  Paso al siguiente PID.', ...
                    Iset(j));
            break
        end
                
        
    end

   

    save(sprintf('Iset%g.mat', Iset(j)), ...
     'x','T_LK','lksPower', ...
     'Pset','Tset','Dset','j');
end

%pongo valores de PID que ya conocemos que funciona al terminar las medidas
fprintf(lks, 'PID 0,100,150,0\n');
fprintf(lks, sprintf('SETP 0,%.6f\n', 0.040));

disp('Barrido de PID terminado.')
