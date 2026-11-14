function res = probar_multiregistro(dev, varargin)
%PROBAR_MULTIREGISTRO  Prueba autocontenida de adquisicion multirregistro con la PXI-5922 (v2).
%
%   Configura la tarjeta para capturar N registros con un solo arme y los
%   recoge MIENTRAS la tarjeta sigue adquiriendo, por bloques y llamando
%   directamente a la DLL de NI-SCOPE (sin pasar por invoke/get/set del
%   .mdd, que es lo que hacia lenta la v1). Analiza los timestamps de cada
%   registro para estimar el ciclo entre registros y el tiempo muerto.
%
%   Uso:
%     res = probar_multiregistro('PXI1Slot2')              % abre y cierra la sesion
%     res = probar_multiregistro(pxi, 'NumRecords', 1000)  % usa un icdevice ya conectado
%
%   Parametros nombre-valor (valores por defecto entre parentesis):
%     --- Configuracion de la tarjeta ---
%     'Driver'           ('pxi5922.mdd')
%     'Channel'          ('0')        un solo canal
%     'VRange'           (1)          rango vertical total en V
%     'VOffset'          (0)          offset vertical en V
%     'Coupling'         ('DC')       'AC' | 'DC' | 'GND'
%     'SampleRate'       (1e6)        frecuencia de muestreo minima en S/s
%     'RecordLength'     (2000)       longitud minima del registro en muestras
%     'RefPosition'      (20)         posicion del trigger en % del registro
%     'NumRecords'       (100)        numero total de registros
%     'Trigger'          ('immediate') 'immediate' | 'edge'
%     'TrigSource'       ('0')        canal o terminal ('VAL_EXTERNAL', 'VAL_PFI_0', ...)
%     'TrigLevel'        (0.1)        V
%     'TrigSlope'        ('rising')   'rising' | 'falling'
%     'Holdoff'          (0)          s
%     --- Recogida ---
%     'FetchMode'        ('block')    'block'  : varios registros por llamada
%                                     'record' : uno por llamada (mas lento, siempre seguro)
%     'BlockSize'        (100)        registros maximos por llamada en modo 'block'
%     'Verify'           (true)       compara el primer bloque con recogidas individuales
%     'ContinuousMemory' (false)      true: la memoria de la tarjeta funciona como buffer
%                                     circular y NumRecords puede superar su capacidad,
%                                     siempre que la recogida siga el ritmo
%     'KeepData'         (true)       false: solo guarda timestamps (para series muy largas)
%     'BytesPerSample'   (4)          bytes por muestra en memoria, para la ESTIMACION de
%                                     capacidad (la comprobacion definitiva la hace el driver)
%     'FetchTimeout'     (5)          s, timeout de cada fetch
%     'MaxWait'          (30)         s maximos SIN registros nuevos antes de abandonar
%     'Plot'             (true)
%
%   NOTA: constantes segun niScope.h (AC=0, DC=1, GND=2; NEGATIVE=0, POSITIVE=1).

%% ---------- Parametros ----------
p = inputParser;
p.FunctionName = 'probar_multiregistro';
if any(strcmp(methods(p), 'addParameter'))
    addP = @(n, v) addParameter(p, n, v);
else
    addP = @(n, v) addParamValue(p, n, v); %#ok<NVREPL> % versiones antiguas de MATLAB
end
addP('Driver',           'pxi5922.mdd');
addP('Channel',          '0');
addP('VRange',           1);
addP('VOffset',          0);
addP('Coupling',         'DC');
addP('SampleRate',       1e6);
addP('RecordLength',     2000);
addP('RefPosition',      20);
addP('NumRecords',       100);
addP('Trigger',          'immediate');
addP('TrigSource',       '0');
addP('TrigLevel',        0.1);
addP('TrigSlope',        'rising');
addP('Holdoff',          0);
addP('FetchMode',        'block');
addP('BlockSize',        100);
addP('Verify',           true);
addP('ContinuousMemory', false);
addP('KeepData',         true);
addP('BytesPerSample',   4);
addP('FetchTimeout',     5);
addP('MaxWait',          30);
addP('Plot',             true);
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

% IDs de atributos de NI-SCOPE (los mismos que usa el .mdd)
ID.RECORDS_DONE     = 1150083;
ID.FETCH_REC_NUM    = 1150079;
ID.FETCH_NUM_REC    = 1150080;
ID.ENABLE_REC_MEM   = 1150068;
ID.MEMORY_SIZE      = 1150069;
ID.NUM_CHANNELS     = 1050203;

%% ---------- Sesion ----------
% Primero se comprueba si es texto; asi no se llama a isstring sobre el objeto
% (isstring no existe en versiones de MATLAB anteriores a R2016b).
if exist('isstring') > 0 && isstring(dev) %#ok<EXIST>
    dev = char(dev);
end
if ischar(dev)
    pxi = icdevice(o.Driver, dev);
    connect(pxi);
    cerrarAlFinal = true;
else
    pxi = dev;
    cerrarAlFinal = false;
end

% Acceso directo a la DLL: el mismo nombre de libreria y sesion que usa el .mdd
L.lib = get(pxi, 'DriverName');
L.ses = get(pxi, 'Interface');
L.ID  = ID;

limpieza = onCleanup(@() limpiar(pxi, L, cerrarAlFinal)); %#ok<NASGU>

gAcq  = get(pxi, 'Acquisition');
gVert = get(pxi, 'ConfigurationFunctionsVertical');
gHor  = get(pxi, 'ConfigurationFunctionsHorizontal');
gTrig = get(pxi, 'ConfigurationFunctionsTrigger');
gAct  = get(pxi, 'ConfigurationFunctionsActualValues');

%% ---------- Configuracion ----------
invoke(gAcq, 'abort');
invoke(gVert, 'configurevertical', ch, o.VRange, o.VOffset, cpl, 1, 1);
invoke(gHor, 'configurehorizontaltiming', o.SampleRate, o.RecordLength, ...
       o.RefPosition, o.NumRecords, 1);
switch lower(o.Trigger)
    case 'immediate'
        invoke(gTrig, 'configuretriggerimmediate');
    case 'edge'
        invoke(gTrig, 'configuretriggeredge', char(o.TrigSource), o.TrigLevel, ...
               slope, TRIG_COUPLING_DC, o.Holdoff, 0);
    otherwise
        error('Trigger no valido: %s', o.Trigger);
end
setBool(L, ID.ENABLE_REC_MEM, o.ContinuousMemory);

recLen = invoke(gAct, 'actualrecordlength');
fs     = invoke(gAct, 'samplerate');
recDur = recLen / fs;
nRec   = o.NumRecords;

%% ---------- Comprobacion de memoria ----------
memTot  = getI32(L, ID.MEMORY_SIZE);       % bytes, todos los canales
nChTot  = getI32(L, ID.NUM_CHANNELS);
memCh   = memTot / nChTot;
maxRecEst = floor(memCh / (recLen * o.BytesPerSample));

fprintf('\n--- Configuracion efectiva ---\n');
fprintf('  Frecuencia de muestreo : %.6g S/s\n', fs);
fprintf('  Longitud de registro   : %d muestras (%.4g ms)\n', recLen, 1e3*recDur);
fprintf('  Pretrigger             : %.1f %% (%.4g ms)\n', o.RefPosition, 1e3*recDur*o.RefPosition/100);
fprintf('  Registros pedidos      : %d\n', nRec);
fprintf('  Memoria de la tarjeta  : %.1f MB total, %.1f MB por canal\n', memTot/2^20, memCh/2^20);
fprintf('  Capacidad estimada     : ~%d registros (estimacion con %d bytes/muestra)\n', ...
        maxRecEst, o.BytesPerSample);
fprintf('  Memoria circular       : %d\n', o.ContinuousMemory);

if ~o.ContinuousMemory && nRec > maxRecEst
    warning('probar_multiregistro:memoria', ...
        ['Se piden %d registros y la capacidad estimada es ~%d. ' ...
         'El driver lo confirmara al aplicar la configuracion.'], nRec, maxRecEst);
end

% Commit: el driver valida la configuracion completa (incluida la memoria)
st = calllib(L.lib, 'niScope_Commit', L.ses);
if st < 0
    msg = errDesc(L, st);
    if ~o.ContinuousMemory
        error('probar_multiregistro:commit', ...
            ['El driver rechaza la configuracion (%d): %s\n' ...
             'Capacidad estimada: ~%d registros. Reduce NumRecords o RecordLength, ' ...
             'o usa ''ContinuousMemory'', true.'], st, msg, maxRecEst);
    else
        error('probar_multiregistro:commit', 'El driver rechaza la configuracion (%d): %s', st, msg);
    end
end

bytesRAM = recLen * nRec * 8;
if o.KeepData && bytesRAM > 2e9
    warning('probar_multiregistro:ram', ...
        'Guardar todos los datos ocupara %.1f GB de RAM. Considera ''KeepData'', false.', bytesRAM/1e9);
end

%% ---------- Reserva de resultados ----------
if o.KeepData
    data = zeros(recLen, nRec);
else
    data = [];
end
absX = zeros(1, nRec);
relX = zeros(1, nRec);
dx   = zeros(1, nRec);
nAct = zeros(1, nRec);

modo = lower(o.FetchMode);
if strcmp(modo, 'record')
    blk = 1;
else
    blk = max(1, round(o.BlockSize));
end
verificado = ~o.Verify;

%% ---------- Arme y recogida simultanea ----------
fprintf('\n--- Adquisicion ---\n');
fetched     = 0;
lastDone    = 0;
maxBacklog  = 0;
tFetchTot   = 0;
nCalls      = 0;
tArm        = tic;
tNuevo      = tic;   % tiempo desde el ultimo registro nuevo
tUltFetch   = tic;
tAviso      = 0;

invoke(gAcq, 'initiateacquisition');

while fetched < nRec
    done = getI32(L, ID.RECORDS_DONE);
    if done > lastDone
        lastDone = done;
        tNuevo = tic;
    end
    avail = min(done, nRec) - fetched;
    if avail > maxBacklog
        maxBacklog = avail;
    end

    if avail > 0 && (avail >= blk || done >= nRec || toc(tUltFetch) > 0.2)
        n = min(avail, blk);
        tf = tic;
        try
            [w, a, r, d, na, modo] = recoger(L, ch, fetched, n, recLen, o.FetchTimeout, modo);
        catch err
            if o.ContinuousMemory
                error('probar_multiregistro:fetch', ...
                    ['Fallo al recoger el registro %d: %s\n' ...
                     'Con memoria circular, lo mas probable es que la tarjeta haya ' ...
                     'sobrescrito registros no recogidos (la recogida no siguio el ritmo).'], ...
                    fetched, err.message);
            else
                rethrow(err);
            end
        end
        tFetchTot = tFetchTot + toc(tf);
        nCalls = nCalls + 1;

        % Verificacion del primer bloque: se repite en modo 'record' y se compara
        if ~verificado && n > 1 && strcmp(modo, 'block')
            ok = verificarBloque(L, ch, fetched, n, recLen, o.FetchTimeout, w, a, r);
            if ~ok
                warning('probar_multiregistro:verificacion', ...
                    ['La recogida por bloques no coincide con la individual. ' ...
                     'Se pasa a modo ''record'' y se repite el bloque.']);
                modo = 'record';
                blk = 1;
                [w, a, r, d, na] = recogerIndividual(L, ch, fetched, n, recLen, o.FetchTimeout);
            else
                fprintf('  Verificacion del primer bloque: OK (%d registros)\n', n);
            end
            verificado = true;
        end
        if strcmp(modo, 'record')
            blk = 1;
        end

        idx = fetched + (1:n);
        if o.KeepData
            data(:, idx) = w;
        end
        absX(idx) = a; relX(idx) = r; dx(idx) = d; nAct(idx) = na;
        fetched = fetched + n;
        tUltFetch = tic;
    else
        if toc(tNuevo) > o.MaxWait
            warning('probar_multiregistro:timeout', ...
                '%.0f s sin registros nuevos: %d/%d completados, %d recogidos.', ...
                o.MaxWait, done, nRec, fetched);
            break
        end
        pause(0.002);   % cede el control (timers, interfaz)
    end

    t = toc(tArm);
    if t - tAviso > 1
        fprintf('  t=%6.1f s | completados %d | recogidos %d | pendientes %d\n', ...
                t, done, fetched, done - fetched);
        tAviso = t;
    end
end
tTotal = toc(tArm);
nGot = fetched;

if nGot == 0
    error('No se recogio ningun registro. Revisa trigger y senal.');
end
if nGot < nRec
    if o.KeepData, data = data(:, 1:nGot); end
    absX = absX(1:nGot); relX = relX(1:nGot); dx = dx(1:nGot); nAct = nAct(1:nGot);
end

%% ---------- Analisis ----------
tTrig = absX - relX;
dT    = diff(tTrig);

stats = struct();
stats.timestampsValidos = any(absX ~= 0) && nGot > 1;
stats.duracionRegistro  = recDur;
stats.tiempoTotal       = tTotal;
stats.tiempoRecogida    = tFetchTot;
stats.llamadasFetch     = nCalls;
stats.msPorRegistro     = 1e3 * tFetchTot / nGot;
stats.ritmoMaxRecogida  = nGot / tFetchTot;     % registros/s que la recogida puede sostener
stats.maxPendientes     = maxBacklog;
stats.capacidadEstimada = maxRecEst;
stats.modoFinal         = modo;

fprintf('\n--- Resultados ---\n');
fprintf('  Recogidos               : %d registros en %.3f s (modo final: %s)\n', nGot, tTotal, modo);
fprintf('  Coste de recogida       : %.3f ms/registro (%d llamadas)\n', stats.msPorRegistro, nCalls);
fprintf('  Ritmo max. de recogida  : ~%.0f registros/s\n', stats.ritmoMaxRecogida);
fprintf('  Max. registros pendientes: %d (capacidad estimada ~%d)\n', maxBacklog, maxRecEst);
if o.ContinuousMemory && maxBacklog > 0.5 * maxRecEst
    warning('probar_multiregistro:backlog', ...
        'Los registros pendientes llegaron al %.0f %% de la capacidad: margen escaso.', ...
        100 * maxBacklog / maxRecEst);
end

if ~stats.timestampsValidos
    warning('probar_multiregistro:timestamps', ...
        'absoluteInitialX es cero: el driver/tarjeta no esta devolviendo timestamps absolutos.');
else
    stats.dTmin = min(dT);
    stats.dTmed = mean(dT);
    stats.dTmax = max(dT);
    stats.ritmoMedioTimestamps = 1 / stats.dTmed;
    stats.tiempoMuertoMin = stats.dTmin - recDur;
    fprintf('  Intervalo entre triggers: min %.4g ms | media %.4g ms | max %.4g ms\n', ...
        1e3*stats.dTmin, 1e3*stats.dTmed, 1e3*stats.dTmax);
    fprintf('  Ritmo medio (timestamps): %.4g Hz\n', stats.ritmoMedioTimestamps);
    fprintf('  Tiempo muerto minimo    : %.4g us\n', 1e6*stats.tiempoMuertoMin);
end
if any(nAct ~= recLen)
    warning('probar_multiregistro:muestras', ...
        'Algunos registros tienen actualSamples distinto de %d.', recLen);
end

%% ---------- Salida ----------
res = struct();
res.data          = data;
res.t             = (0:recLen-1).' / fs;
res.absX          = absX;
res.relX          = relX;
res.tTrig         = tTrig;
res.dT            = dT;
res.xIncrement    = dx;
res.actualSamples = nAct;
res.config        = o;
res.efectiva      = struct('fs', fs, 'recLen', recLen, 'memoriaTotal', memTot, ...
                           'memoriaPorCanal', memCh, 'recordsFetched', nGot);
res.stats         = stats;

%% ---------- Graficas ----------
if o.Plot
    figure('Name', 'Prueba multirregistro');
    subplot(2, 1, 1);
    if o.KeepData
        nVer = min(nGot, 20);
        plot(1e3*(res.t + relX(1)), data(:, 1:nVer));
        xlabel('Tiempo respecto al trigger (ms)'); ylabel('V');
        title(sprintf('Primeros %d registros de %d', nVer, nGot));
        grid on;
    else
        text(0.5, 0.5, 'KeepData = false', 'HorizontalAlignment', 'center'); axis off;
    end
    subplot(2, 1, 2);
    if stats.timestampsValidos
        hist(1e3*dT, 50); %#ok<HIST> compatible con versiones antiguas
        xlabel('Intervalo entre triggers (ms)'); ylabel('Cuentas');
        title('Intervalos entre registros (timestamps de la tarjeta)');
        grid on;
    else
        text(0.5, 0.5, 'Sin timestamps validos', 'HorizontalAlignment', 'center'); axis off;
    end
end
end

%% =====================================================================
%  Recogida
%% =====================================================================
function [w, a, r, d, na, modo] = recoger(L, ch, first, n, recLen, timeout, modo)
if strcmp(modo, 'block') && n > 1
    try
        [w, a, r, d, na] = recogerBloque(L, ch, first, n, recLen, timeout);
        return
    catch err
        % Errores de MATLAB (tipos de puntero no admitidos, etc.): se vuelve al modo seguro
        if isempty(strfind(err.identifier, 'probar_multiregistro')) %#ok<STREMP>
            warning('probar_multiregistro:bloque', ...
                'La recogida por bloques no es posible (%s). Se usa el modo ''record''.', err.message);
            modo = 'record';
        else
            rethrow(err);
        end
    end
end
[w, a, r, d, na] = recogerIndividual(L, ch, first, n, recLen, timeout);
end

function [w, a, r, d, na] = recogerBloque(L, ch, first, n, recLen, timeout)
% Varios registros en una sola llamada a niScope_Fetch.
% Las estructuras niScope_wfmInfo se reciben en un buffer reservado como
% doubles (mas grande de lo necesario, por seguridad) y se interpretan con
% la disposicion estandar de 64 bytes: 3 doubles, int32 + relleno, 4 doubles.
% 'Verify' comprueba que esta interpretacion es correcta.
STRIDE = 8;                                   % doubles por estructura (64 bytes)
setI32(L, L.ID.FETCH_REC_NUM, first);
setI32(L, L.ID.FETCH_NUM_REC, n);

wp  = libpointer('doublePtr', zeros(recLen * n, 1));
buf = libpointer('doublePtr', zeros(2 * STRIDE * n, 1));   % margen x2
setdatatype(buf, 'niScope_wfmInfoPtr');

st = calllib(L.lib, 'niScope_Fetch', L.ses, cs(ch), timeout, recLen, wp, buf);
chk(L, st, 'niScope_Fetch (bloque)');

w = reshape(wp.Value, recLen, n);
setdatatype(buf, 'doublePtr', 2 * STRIDE * n);
v = reshape(buf.Value(1:STRIDE * n), STRIDE, n);
a = v(1, :);
r = v(2, :);
d = v(3, :);
na = zeros(1, n);
for k = 1:n
    t = typecast(v(4, k), 'int32');
    na(k) = double(t(1));
end
end

function [w, a, r, d, na] = recogerIndividual(L, ch, first, n, recLen, timeout)
% Un registro por llamada, con una unica estructura wfmInfo (siempre seguro).
info0 = struct('absoluteInitialX', 0, 'relativeInitialX', 0, 'xIncrement', 0, ...
               'actualSamples', 0, 'offset', 0, 'gain', 0, ...
               'reserved1', 0, 'reserved2', 0);
w = zeros(recLen, n); a = zeros(1, n); r = zeros(1, n); d = zeros(1, n); na = zeros(1, n);
setI32(L, L.ID.FETCH_NUM_REC, 1);
for k = 1:n
    setI32(L, L.ID.FETCH_REC_NUM, first + k - 1);
    wp = libpointer('doublePtr', zeros(recLen, 1));
    ip = libstruct('niScope_wfmInfo', info0);
    st = calllib(L.lib, 'niScope_Fetch', L.ses, cs(ch), timeout, recLen, wp, ip);
    chk(L, st, 'niScope_Fetch (registro)');
    w(:, k) = wp.Value(:);
    a(k) = ip.absoluteInitialX;
    r(k) = ip.relativeInitialX;
    d(k) = ip.xIncrement;
    na(k) = double(ip.actualSamples);
end
end

function ok = verificarBloque(L, ch, first, n, recLen, timeout, w, a, r)
% Repite el primer y el ultimo registro del bloque de forma individual y compara.
idx = [1, n];
[w1, a1, r1] = recogerIndividual(L, ch, first + idx(1) - 1, 1, recLen, timeout);
[w2, a2, r2] = recogerIndividual(L, ch, first + idx(2) - 1, 1, recLen, timeout);
tolV = 1e-12 + 1e-9 * max(abs([w1; w2]));
ok = max(abs(w(:, idx(1)) - w1)) <= tolV && max(abs(w(:, idx(2)) - w2)) <= tolV && ...
     abs(a(idx(1)) - a1) < 1e-12 && abs(a(idx(2)) - a2) < 1e-12 && ...
     abs(r(idx(1)) - r1) < 1e-12 && abs(r(idx(2)) - r2) < 1e-12;
end

%% =====================================================================
%  Acceso directo a atributos y errores
%% =====================================================================
function c = cs(s)
% Cadena C terminada en cero, igual que la construye el .mdd
c = [double(s) 0];
end

function v = getI32(L, id)
pv = libpointer('int32Ptr', 0);
st = calllib(L.lib, 'niScope_GetAttributeViInt32', L.ses, cs(''), id, pv);
chk(L, st, sprintf('GetAttributeViInt32(%d)', id));
v = double(pv.Value);
end

function setI32(L, id, v)
st = calllib(L.lib, 'niScope_SetAttributeViInt32', L.ses, cs(''), id, v);
chk(L, st, sprintf('SetAttributeViInt32(%d)', id));
end

function setBool(L, id, v)
st = calllib(L.lib, 'niScope_SetAttributeViBoolean', L.ses, cs(''), id, double(logical(v)));
chk(L, st, sprintf('SetAttributeViBoolean(%d)', id));
end

function chk(L, st, fn)
if st < 0
    error('probar_multiregistro:niscope', '%s fallo (%d): %s', fn, st, errDesc(L, st));
end
end

function msg = errDesc(L, st)
msg = 'sin descripcion';
try
    src  = libpointer('int8Ptr', zeros(1, 256));
    desc = libpointer('int8Ptr', zeros(1, 1024));
    calllib(L.lib, 'niScope_errorHandler', L.ses, st, src, desc);
    v = double(desc.Value);
    z = find(v == 0, 1);
    if ~isempty(z), v = v(1:z-1); end
    v(v < 0) = v(v < 0) + 256;
    msg = char(v);
catch
end
end

function limpiar(pxi, L, cerrar)
% Deja la tarjeta en reposo, restaura atributos de recogida y cierra si procede.
try, calllib(L.lib, 'niScope_Abort', L.ses); catch, end
try, setI32(L, L.ID.FETCH_REC_NUM, 0); catch, end
try, setI32(L, L.ID.FETCH_NUM_REC, -1); catch, end
try, setBool(L, L.ID.ENABLE_REC_MEM, false); catch, end
if cerrar
    try
        disconnect(pxi);
        delete(pxi);
    catch
    end
end
end
