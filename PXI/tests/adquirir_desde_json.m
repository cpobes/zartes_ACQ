function res = adquirir_desde_json(fichConfig, dev)
%ADQUIRIR_DESDE_JSON  Adquisicion multirregistro configurada con JSON y guardada en HDF5.
%
%   res = adquirir_desde_json('config_ejemplo.json')        % abre el recurso indicado en el JSON
%   res = adquirir_desde_json('config_ejemplo.json', pxi)   % usa una sesion icdevice ya abierta
%
%   - Lee la configuracion (admite lineas de comentario //).
%     Usa jsondecode si existe (R2016b+) o loadjson (JSONlab) en versiones anteriores.
%   - Llama a probar_multiregistro, que recoge los registros por bloques.
%   - Cada bloque se escribe en el HDF5 en cuanto llega (no se acumula en RAM).
%   - Al final guarda la configuracion original, la efectiva y las estadisticas.
%
%   Estructura del fichero HDF5:
%     /                      atributos: config_json (texto original), created, matlab_version,
%                            software, meta_<campo> (de "metadata"), stats_<campo>
%     /records/data          [muestras x registros] en V
%     /records/t_trigger     [1 x registros] instante de cada trigger (s)
%     /records/absoluteInitialX, /records/relativeInitialX, /records/actual_samples
%     /records/data          atributos: sample_rate_Hz, record_length, ref_position_pct, ...

%% ---------- Configuracion ----------
[cfg, txt] = leerConfig(fichConfig);

carpeta = getf(cfg, {'output', 'folder'}, '.');
if ~exist(carpeta, 'dir'), mkdir(carpeta); end
prefijo = getf(cfg, {'output', 'file_prefix'}, 'run');
tipo    = getf(cfg, {'output', 'data_type'}, 'double');
nivelZ  = getf(cfg, {'output', 'compression'}, 0);
blk     = getf(cfg, {'acquisition', 'block_size'}, 100);

fich = fullfile(carpeta, sprintf('%s_%s.h5', prefijo, datestr(now, 'yyyymmdd_HHMMSS')));
if exist(fich, 'file')
    error('El fichero %s ya existe.', fich);
end

%% ---------- Fichero HDF5: datasets de tiempos y atributos iniciales ----------
% Los datasets son extensibles (Inf): crecen con cada bloque.
for nombre = {'t_trigger', 'absoluteInitialX', 'relativeInitialX', 'actual_samples'}
    h5create(fich, ['/records/' nombre{1}], [1 Inf], 'ChunkSize', [1 1024]);
end
h5writeatt(fich, '/', 'config_json', txt);
h5writeatt(fich, '/', 'config_file', fichConfig);
h5writeatt(fich, '/', 'created', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
h5writeatt(fich, '/', 'matlab_version', version);
h5writeatt(fich, '/', 'software', 'adquirir_desde_json + probar_multiregistro v2');

meta = getf(cfg, {'metadata'}, struct());
campos = fieldnames(meta);
for k = 1:numel(campos)
    v = meta.(campos{k});
    if islogical(v), v = double(v); end
    if isempty(v), v = ''; end
    h5writeatt(fich, '/', ['meta_' campos{k}], v);
end

datosCreado = false;   % el dataset de datos se crea con el primer bloque (ahi se conoce recLen)

%% ---------- Adquisicion ----------
if nargin < 2 || isempty(dev)
    dev = getf(cfg, {'device', 'resource'}, '');
    if isempty(dev), error('Falta device.resource en la configuracion.'); end
end

args = { ...
    'Driver',           getf(cfg, {'device', 'driver'}, 'pxi5922.mdd'), ...
    'Channel',          getf(cfg, {'channel', 'name'}, '0'), ...
    'VRange',           getf(cfg, {'channel', 'range_V'}, 1), ...
    'VOffset',          getf(cfg, {'channel', 'offset_V'}, 0), ...
    'Coupling',         getf(cfg, {'channel', 'coupling'}, 'DC'), ...
    'SampleRate',       getf(cfg, {'horizontal', 'sample_rate_Hz'}, 1e6), ...
    'RecordLength',     getf(cfg, {'horizontal', 'record_length'}, 2000), ...
    'RefPosition',      getf(cfg, {'horizontal', 'ref_position_pct'}, 20), ...
    'NumRecords',       getf(cfg, {'horizontal', 'num_records'}, 100), ...
    'Trigger',          getf(cfg, {'trigger', 'type'}, 'immediate'), ...
    'TrigSource',       getf(cfg, {'trigger', 'source'}, '0'), ...
    'TrigLevel',        getf(cfg, {'trigger', 'level_V'}, 0.1), ...
    'TrigSlope',        getf(cfg, {'trigger', 'slope'}, 'rising'), ...
    'Holdoff',          getf(cfg, {'trigger', 'holdoff_s'}, 0), ...
    'FetchMode',        getf(cfg, {'acquisition', 'fetch_mode'}, 'block'), ...
    'BlockSize',        blk, ...
    'Verify',           logical(getf(cfg, {'acquisition', 'verify'}, true)), ...
    'ContinuousMemory', logical(getf(cfg, {'acquisition', 'continuous_memory'}, false)), ...
    'MaxWait',          getf(cfg, {'acquisition', 'max_wait_s'}, 30), ...
    'KeepData',         false, ...
    'Plot',             false, ...
    'OnBlock',          @escribirBloque };

fprintf('Guardando en: %s\n', fich);
res = probar_multiregistro(dev, args{:});

%% ---------- Configuracion efectiva y estadisticas ----------
if datosCreado
    ef = res.efectiva;
    h5writeatt(fich, '/records/data', 'units', 'V');
    h5writeatt(fich, '/records/data', 'sample_rate_Hz', ef.fs);
    h5writeatt(fich, '/records/data', 'record_length', ef.recLen);
    h5writeatt(fich, '/records/data', 'ref_position_pct', res.config.RefPosition);
    h5writeatt(fich, '/records/data', 't0_relative_to_trigger_s', res.relX(1));
    h5writeatt(fich, '/records/data', 'records_fetched', ef.recordsFetched);
    h5writeatt(fich, '/records/data', 'board_memory_bytes', ef.memoriaTotal);
end
h5writeatt(fich, '/records/t_trigger', 'description', ...
    'Instante de cada trigger: absoluteInitialX - relativeInitialX (s)');

s = res.stats;
camposS = fieldnames(s);
for k = 1:numel(camposS)
    v = s.(camposS{k});
    if islogical(v), v = double(v); end
    if (isnumeric(v) && isscalar(v)) || ischar(v)
        h5writeatt(fich, '/', ['stats_' camposS{k}], v);
    end
end

res.fichero = fich;
fprintf('Fichero HDF5 completo: %s\n', fich);

%% ---------- Graficas (leidas del propio HDF5) ----------
if logical(getf(cfg, {'output', 'plot'}, true)) && datosCreado
    nVer = min(getf(cfg, {'output', 'plot_records'}, 20), res.efectiva.recordsFetched);
    x  = h5read(fich, '/records/data', [1 1], [Inf nVer]);
    fsP = h5readatt(fich, '/records/data', 'sample_rate_Hz');
    t0 = h5readatt(fich, '/records/data', 't0_relative_to_trigger_s');
    tt = h5read(fich, '/records/t_trigger');
    tEje = 1e3 * ((0:size(x, 1)-1).' / fsP + t0);

    figure('Name', sprintf('Adquisicion: %s', fich));
    subplot(2, 1, 1);
    plot(tEje, x);
    xlabel('Tiempo respecto al trigger (ms)'); ylabel('V');
    title(sprintf('Primeros %d registros de %d', nVer, res.efectiva.recordsFetched));
    grid on;
    subplot(2, 1, 2);
    if numel(tt) > 1 && any(tt ~= 0)
        hist(1e3 * diff(tt), 50); %#ok<HIST>
        xlabel('Intervalo entre triggers (ms)'); ylabel('Cuentas');
        title('Intervalos entre registros');
        grid on;
    else
        text(0.5, 0.5, 'Sin timestamps validos', 'HorizontalAlignment', 'center'); axis off;
    end
end

    %% ---------- Escritura por bloques (funcion anidada: comparte variables) ----------
    function escribirBloque(idx, w, a, r, ~, na)
        nB = numel(idx);
        if ~datosCreado
            recLen = size(w, 1);
            bytesMuestra = 8; if strcmp(tipo, 'single'), bytesMuestra = 4; end
            % Chunks de ~4 MB como maximo, alineados con los bloques
            chunkRec = max(1, min(blk, floor(4e6 / (recLen * bytesMuestra))));
            opts = {'Datatype', tipo, 'ChunkSize', [recLen chunkRec]};
            if nivelZ > 0, opts = [opts, {'Deflate', nivelZ}]; end
            h5create(fich, '/records/data', [recLen Inf], opts{:});
            datosCreado = true;
        end
        h5write(fich, '/records/data', cast(w, tipo), [1 idx(1)], size(w));
        h5write(fich, '/records/t_trigger',        a - r, [1 idx(1)], [1 nB]);
        h5write(fich, '/records/absoluteInitialX', a,     [1 idx(1)], [1 nB]);
        h5write(fich, '/records/relativeInitialX', r,     [1 idx(1)], [1 nB]);
        h5write(fich, '/records/actual_samples',   na,    [1 idx(1)], [1 nB]);
    end
end

%% =====================================================================
function [cfg, txt] = leerConfig(fich)
% Lee JSON con lineas de comentario // (JSONC). Solo se eliminan lineas
% completas de comentario, para no romper cadenas que contengan '//'.
txt = fileread(fich);
limpio = regexprep(txt, '(?m)^\s*//[^\n]*$', '');
if exist('jsondecode') > 0 %#ok<EXIST>
    cfg = jsondecode(limpio);
elseif exist('loadjson') > 0 %#ok<EXIST>
    cfg = loadjson(limpio);
else
    error('No hay lector de JSON: se necesita jsondecode (R2016b+) o loadjson (JSONlab).');
end
end

function v = getf(s, ruta, porDefecto)
% Lee un campo anidado (ruta = {'a','b'}) o devuelve el valor por defecto.
v = s;
for k = 1:numel(ruta)
    if isstruct(v) && isfield(v, ruta{k})
        v = v.(ruta{k});
    else
        v = porDefecto;
        return
    end
end
end
