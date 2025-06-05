function datos = LKS_Valero_readHeaterPower(puerto, archivoSalida)
% LKS_ReadHeaterPower Lee y grafica continuamente la potencia del heater A en vatios.
%   datos = leerPotenciaHeaterWatts(puerto, archivoSalida)
%   puerto         - Nombre del puerto serie (ej. 'COM3' o '/dev/ttyUSB0')
%   archivoSalida  - Nombre del archivo CSV donde guardar los datos
%
%   Devuelve una tabla con columnas: Tiempo, Potencia (W)

    % Configuración del puerto serie
    baudRate = 57600;
    ls350 = serialport(puerto, baudRate);
    configureTerminator(ls350, 'LF');
    flush(ls350);

    % Leer configuración del heater para obtener la potencia máxima
    writeline(ls350, 'HTRSET? 1');
    respuesta = readline(ls350);
    partes = strsplit(strtrim(respuesta), ',');
    Pmax = str2double(partes{2});  % Potencia máxima en W

    if isnan(Pmax)
        error('No se pudo leer la potencia máxima del heater.');
    end

    % Preparar archivo CSV
    fid = fopen(archivoSalida, 'w');
    fprintf(fid, 'Tiempo,Potencia_W\n');

    % Inicialización de arrays
    tiempos = datetime.empty;
    potenciasW = [];

    % Preparar gráfica
    figure('Name','Potencia Heater A en Vatios (Lake Shore 350)', 'NumberTitle','off');
    hPlot = plot(NaT, [], '-o');
    xlabel('Tiempo'); ylabel('Potencia (W)');
    title('Lectura en tiempo real');
    grid on;
    ylim([0 Pmax * 1.05]);

    fprintf('Leyendo datos en vatios... Presiona Ctrl+C para detener.\n');
    fprintf('Potencia máxima configurada: %.2f W\n', Pmax);

    try
        while true
            % Leer porcentaje de potencia
            writeline(ls350, 'HTR? 1');
            porcentaje = str2double(strtrim(readline(ls350)));

            % Convertir a vatios
            potenciaW = (porcentaje / 100) * Pmax;
            t = datetime('now');

            % Guardar datos
            tiempos(end+1, 1) = t; %#ok<AGROW>
            potenciasW(end+1, 1) = potenciaW; %#ok<AGROW>
            fprintf(fid, '%s,%.3f\n', datestr(t, 'yyyy-mm-dd HH:MM:SS.FFF'), potenciaW);

            % Actualizar gráfica
            set(hPlot, 'XData', tiempos, 'YData', potenciasW);
            xlim([t - seconds(60), t + seconds(5)]);
            drawnow;

            pause(0.5);
        end
    catch
        fprintf('\nLectura interrumpida por el usuario.\n');
        fclose(fid);
        clear ls350;

        % Devolver los datos como tabla
        datos = table(tiempos, potenciasW, 'VariableNames', {'Tiempo', 'Potencia_W'});
    end
end


%%Para usarla utilizar
%%datos = leerPotenciaHeater("COM3", "potencia_heater.csv");

