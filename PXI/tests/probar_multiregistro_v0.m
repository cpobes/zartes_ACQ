function res = probar_multiregistro(dev, varargin)
%PROBAR_MULTIREGISTRO  Prueba autocontenida de adquisicion multirregistro con la PXI-5922.
%
%   Configura la tarjeta para capturar N registros con un solo arme
%   (initiateacquisition), espera a que se completen sondeando Records_Done,
%   los recoge uno a uno y analiza los timestamps de cada registro para
%   estimar el ciclo entre registros y el tiempo muerto de hardware.
%
%   Uso:
%     res = probar_multiregistro('PXI1Slot2')               % abre y cierra la sesion
%     res = probar_multiregistro(pxi, 'NumRecords', 200)    % usa un icdevice ya conectado
%
%   Prueba 1 (sin generador): 'Trigger','immediate'
%       La tarjeta encadena los registros tan rapido como puede, asi que
%       min(dT) - duracion del registro = tiempo de rearme por hardware.
%   Prueba 2 (con generador): 'Trigger','edge', 'TrigSource','0' (o externo)
%       Registros disparados por pulsos reales.
%
%   Parametros nombre-valor (valores por defecto entre parentesis):
%     'Driver'        ('pxi5922.mdd')
%     'Channel'       ('0')        canal a adquirir
%     'VRange'        (1)          rango vertical total en V (p.ej. 1 -> +-0.5 V)
%     'VOffset'       (0)          offset vertical en V
%     'Coupling'      ('DC')       'AC' | 'DC' | 'GND'
%     'SampleRate'    (1e6)        frecuencia de muestreo minima en S/s
%     'RecordLength'  (2000)       longitud minima del registro en muestras
%     'RefPosition'   (20)         posicion del trigger en % del registro (pretrigger)
%     'NumRecords'    (100)        numero de registros por arme
%     'Trigger'       ('immediate') 'immediate' | 'edge'
%     'TrigSource'    ('0')        canal ('0','1') o terminal ('VAL_EXTERNAL', 'VAL_PFI_0', ...)
%     'TrigLevel'     (0.1)        nivel de trigger en V
%     'TrigSlope'     ('rising')   'rising' | 'falling'
%     'Holdoff'       (0)          holdoff de trigger en s
%     'FetchTimeout'  (5)          timeout de cada fetch en s
%     'MaxWait'       (60)         espera maxima a que se completen los registros, en s
%     'Plot'          (true)       dibujar registros e histograma de intervalos
%
%   Salida: estructura con los datos (muestras x registros), timestamps,
%   configuracion efectiva y estadisticas de tiempos.
%
%   NOTA: las constantes numericas (acoplamiento, pendiente) siguen niScope.h
%   (AC=0, DC=1, GND=2; NEGATIVE=0, POSITIVE=1). Verificalas con tu niScope.h.

%% ---------- Parametros ----------
p = inputParser;
p.FunctionName = 'probar_multiregistro';
addParameter(p, 'Driver',       'pxi5922.mdd');
addParameter(p, 'Channel',      '0');
addParameter(p, 'VRange',       1);
addParameter(p, 'VOffset',      0);
addParameter(p, 'Coupling',     'DC');
addParameter(p, 'SampleRate',   1e6);
addParameter(p, 'RecordLength', 2000);
addParameter(p, 'RefPosition',  20);
addParameter(p, 'NumRecords',   100);
addParameter(p, 'Trigger',      'immediate');
addParameter(p, 'TrigSource',   '0');
addParameter(p, 'TrigLevel',    0.1);
addParameter(p, 'TrigSlope',    'rising');
addParameter(p, 'Holdoff',      0);
addParameter(p, 'FetchTimeout', 5);
addParameter(p, 'MaxWait',      60);
addParameter(p, 'Plot',         true);
parse(p, varargin{:});
o = p.Results;

ch = char(o.Channel);

switch upper(o.Coupling)
    case 'AC',  cpl = 0;
    case 'DC',  cpl = 1;
    case 'GND', cpl = 2;
    otherwise,  error('Coupling no valido: %s', o.Coupling);
end
switch lower(o.TrigSlope)
    case 'rising',  slope = 1;
    case 'falling', slope = 0;
    otherwise,      error('TrigSlope no valido: %s', o.TrigSlope);
end
TRIG_COUPLING_DC = 1;

%% ---------- Sesion ----------
cerrarAlFinal = false;
if ischar(dev) || isstring(dev)
    pxi = icdevice(o.Driver, char(dev));
    connect(pxi);
    cerrarAlFinal = true;
else
    pxi = dev;
end
limpieza = onCleanup(@() limpiar(pxi, cerrarAlFinal)); %#ok<NASGU>

gAcq  = get(pxi, 'Acquisition');
gVert = get(pxi, 'ConfigurationFunctionsVertical');
gHor  = get(pxi, 'ConfigurationFunctionsHorizontal');
gTrig = get(pxi, 'ConfigurationFunctionsTrigger');
gAct  = get(pxi, 'ConfigurationFunctionsActualValues');

%% ---------- Configuracion ----------
invoke(gAcq, 'abort');   % por si quedaba una adquisicion anterior en curso

% Vertical: canal, rango, offset, acoplamiento, atenuacion de sonda, habilitado
invoke(gVert, 'configurevertical', ch, o.VRange, o.VOffset, cpl, 1, 1);

% Horizontal: fs minima, puntos minimos, posicion de referencia (%), n registros, tiempo real
invoke(gHor, 'configurehorizontaltiming', o.SampleRate, o.RecordLength, ...
       o.RefPosition, o.NumRecords, 1);

% Trigger
switch lower(o.Trigger)
    case 'immediate'
        invoke(gTrig, 'configuretriggerimmediate');
    case 'edge'
        invoke(gTrig, 'configuretriggeredge', char(o.TrigSource), o.TrigLevel, ...
               slope, TRIG_COUPLING_DC, o.Holdoff, 0);
    otherwise
        error('Trigger no valido: %s', o.Trigger);
end

% Valores reales tras la coercion de la tarjeta
recLen = invoke(gAct, 'actualrecordlength');
fs     = invoke(gAct, 'samplerate');
nWfm   = invoke(gAct, 'actualnumwfms', ch);
recDur = recLen / fs;

fprintf('\n--- Configuracion efectiva ---\n');
fprintf('  Frecuencia de muestreo : %.6g S/s\n', fs);
fprintf('  Longitud de registro   : %d muestras (%.4g ms)\n', recLen, 1e3*recDur);
fprintf('  Pretrigger             : %.1f %% (%.4g ms)\n', o.RefPosition, 1e3*recDur*o.RefPosition/100);
fprintf('  Registros pedidos      : %d (actualnumwfms = %d)\n', o.NumRecords, nWfm);
fprintf('  Trigger                : %s\n', o.Trigger);

%% ---------- Arme y espera (sin bloquear MATLAB) ----------
nRec = o.NumRecords;
tArm = tic;
invoke(gAcq, 'initiateacquisition');

done = 0;
ultimoAviso = 0;
while done < nRec
    done = get(gAcq, 'Records_Done');
    t = toc(tArm);
    if t - ultimoAviso > 1
        fprintf('  ... %d/%d registros (%.1f s)\n', done, nRec, t);
        ultimoAviso = t;
    end
    if t > o.MaxWait
        warning('probar_multiregistro:timeout', ...
            'Tiempo maximo de espera alcanzado: %d/%d registros completados.', done, nRec);
        break
    end
    pause(0.01);   % cede el control: aqui pueden ejecutarse timers
end
tAdq = toc(tArm);
nGot = min(done, nRec);
fprintf('  Adquisicion: %d registros en %.3f s\n', nGot, tAdq);

if nGot == 0
    error('No se completo ningun registro. Revisa trigger y senal.');
end

%% ---------- Recogida registro a registro ----------
% Se recoge de uno en uno a proposito: el fetch del .mdd solo reserva UNA
% estructura niScope_wfmInfo, y pedir varios registros en una llamada haria
% que el driver escribiera fuera de esa memoria.
info0 = struct('absoluteInitialX', 0, 'relativeInitialX', 0, 'xIncrement', 0, ...
               'actualSamples', 0, 'offset', 0, 'gain', 0, ...
               'reserved1', 0, 'reserved2', 0);

data  = zeros(recLen, nGot);
absX  = zeros(1, nGot);
relX  = zeros(1, nGot);
dx    = zeros(1, nGot);
nAct  = zeros(1, nGot);

set(gAcq, 'Fetch_Number_of_Records', 1);
tF = tic;
for k = 1:nGot
    set(gAcq, 'Fetch_Record_Number', k - 1);   % indice base 0
    [w, wi] = invoke(gAcq, 'fetch', ch, o.FetchTimeout, recLen, zeros(recLen, 1), info0);
    data(:, k) = w(:);
    absX(k) = wi.absoluteInitialX;
    relX(k) = wi.relativeInitialX;
    dx(k)   = wi.xIncrement;
    nAct(k) = wi.actualSamples;
end
tFetch = toc(tF);
% Restaurar valores por defecto del driver para no afectar a otros programas
set(gAcq, 'Fetch_Record_Number', 0);
set(gAcq, 'Fetch_Number_of_Records', -1);

fprintf('  Recogida: %.3f s (%.2f ms por registro)\n', tFetch, 1e3*tFetch/nGot);

%% ---------- Analisis de tiempos ----------
% relativeInitialX = tiempo del primer punto respecto al trigger (negativo con pretrigger)
tTrig = absX - relX;            % instante de cada trigger
dT    = diff(tTrig);            % intervalo entre triggers aceptados

stats = struct();
stats.timestampsValidos = any(absX ~= 0) && nGot > 1;
stats.duracionRegistro  = recDur;
stats.tiempoAdquisicion = tAdq;
stats.tiempoRecogida    = tFetch;
stats.ritmoMedioReloj   = nGot / tAdq;    % segun reloj de MATLAB (incluye espera inicial)

fprintf('\n--- Resultados ---\n');
if ~stats.timestampsValidos
    warning('probar_multiregistro:timestamps', ...
        'absoluteInitialX es cero: el driver/tarjeta no esta devolviendo timestamps absolutos.');
else
    stats.dTmin  = min(dT);
    stats.dTmed  = mean(dT);
    stats.dTmax  = max(dT);
    stats.ritmoMedioTimestamps = 1 / stats.dTmed;
    % Ciclo minimo = duracion del registro + tiempo muerto entre registros
    stats.tiempoMuertoMin = stats.dTmin - recDur;

    fprintf('  Intervalo entre triggers: min %.4g ms | media %.4g ms | max %.4g ms\n', ...
        1e3*stats.dTmin, 1e3*stats.dTmed, 1e3*stats.dTmax);
    fprintf('  Ritmo medio (timestamps): %.4g Hz\n', stats.ritmoMedioTimestamps);
    fprintf('  Duracion del registro   : %.4g ms\n', 1e3*recDur);
    fprintf('  Tiempo muerto minimo    : %.4g us  (min(dT) - duracion del registro)\n', ...
        1e6*stats.tiempoMuertoMin);
    if strcmpi(o.Trigger, 'immediate')
        fprintf('  (Con trigger inmediato, este valor es el rearme por hardware.)\n');
    end
end
if any(nAct ~= recLen)
    warning('probar_multiregistro:muestras', ...
        'Algunos registros tienen actualSamples distinto de %d.', recLen);
end

%% ---------- Salida ----------
res = struct();
res.data       = data;
res.t          = ((0:recLen-1).' * (1/fs));
res.absX       = absX;
res.relX       = relX;
res.tTrig      = tTrig;
res.dT         = dT;
res.xIncrement = dx;
res.actualSamples = nAct;
res.config     = o;
res.efectiva   = struct('fs', fs, 'recLen', recLen, 'numWfms', nWfm, ...
                        'recordsDone', done, 'recordsFetched', nGot);
res.stats      = stats;

%% ---------- Graficas ----------
if o.Plot
    figure('Name', 'Prueba multirregistro');
    subplot(2, 1, 1);
    nVer = min(nGot, 20);
    plot(1e3*(res.t + relX(1)), data(:, 1:nVer));
    xlabel('Tiempo respecto al trigger (ms)'); ylabel('V');
    title(sprintf('Primeros %d registros de %d', nVer, nGot));
    grid on;

    subplot(2, 1, 2);
    if stats.timestampsValidos
        histogram(1e3*dT, 50);
        xlabel('Intervalo entre triggers (ms)'); ylabel('Cuentas');
        title('Intervalos entre registros (timestamps de la tarjeta)');
        grid on;
    else
        text(0.5, 0.5, 'Sin timestamps validos', 'HorizontalAlignment', 'center');
        axis off;
    end
end
end

%% =====================================================================
function limpiar(pxi, cerrar)
% Deja la tarjeta en reposo y, si la sesion se abrio aqui, la cierra.
try
    invoke(get(pxi, 'Acquisition'), 'abort');
catch
end
if cerrar
    try
        disconnect(pxi);
        delete(pxi);
    catch
    end
end
end
