% --- CONFIGURACIÓN INICIAL ---
resourceName = 'PXI1Slot3'; % Cambia por el nombre de tu tarjeta en NI-MAX
channels = '0,1';
sampleRate = 1000000;       % 1 MS/s
numSamplesPerFetch = 50000; % Tamaño del bloque a leer (50 ms de datos a 1MS/s)

% Umbral para el disparo OR por software
threshold = 0.1;            % Voltios

% --- INICIALIZACIÓN DE NI-SCOPE ---
% (Asegúrate de tener instalado el soporte de NI-SCOPE en MATLAB)
scope = niScope(resourceName);

% Configurar canales y muestreo
configureHorizontalTiming(scope, sampleRate, numSamplesPerFetch, 0.0, 1, true);
configureVertical(scope, channels, 5.0, 0.0, niScopeConstants.DC, 1.0, true);

% CLAVE: Configurar disparo inmediato (adquisición continua libre)
configureTriggerImmediate(scope);

% Iniciar la adquisición en el hardware (el búfer circular empieza a llenarse)
initiateAcquisition(scope);

disp('Adquisición continua iniciada. Buscando condición OR...');

try
    while true
        % 1. Extraer el bloque de datos actual del búfer de la tarjeta
        % fetch extrae los datos en paralelo mientras la tarjeta sigue midiendo
        [data, wfmInfo] = fetch(scope, channels, numSamplesPerFetch, 0.0);
       
        % Separar los canales (dependiendo de la estructura de salida de tu driver)
        ch0 = data(:, 1);
        ch1 = data(:, 2);
       
        % 2. LÓGICA OR POR SOFTWARE
        % Evaluamos si alguna señal supera el umbral en el bloque actual
        triggerCH0 = any(ch0-ch0(1) > threshold);
        triggerCH1 = any(ch1-ch1(1) > threshold);
       
        if triggerCH0 || triggerCH1
            disp('¡Disparo OR detectado por Software!');
           
            % Guardar o procesar el bloque donde ocurrió el evento
            evento_detectado = data;
           
            % Aquí puedes romper el bucle o guardar los datos y continuar
            break;
        end
       
        % Opcional: una pequeña pausa para no saturar la CPU de MATLAB,
        % pero asegurando que sea menor al tiempo que tarda en llenarse el bloque.
        pause(0.01);
    end
   
catch ME
    % En caso de error o Ctrl+C, asegurar el cierre del hardware
    disp('Adquisición detenida o error ocurrido.');
    disp(ME.message);
end

% --- LIMPIEZA ---
abort(scope);
close(scope);
clear scope;