function cal = calibrar_memoria(pxi, recLens, varargin)
%CALIBRAR_MEMORIA  Mide cuantos registros admite realmente la PXI-5922 segun la longitud de registro.
%
%   cal = calibrar_memoria(pxi)                       % longitudes por defecto
%   cal = calibrar_memoria(pxi, [500 2000 10000 40000])
%
%   Para cada longitud de registro busca (por biseccion) el maximo NumRecords
%   que el driver acepta en niScope_Commit, sin adquirir nada. Con esos datos
%   ajusta el consumo de memoria por registro a una recta:
%
%       bytes por registro = bytesPorMuestra * recLen + sobrecostePorRegistro
%
%   pxi debe ser un icdevice ya conectado. Parametros opcionales:
%     'Channel'    ('0')
%     'SampleRate' (1e6)
%     'MaxRecords' (1e7)   limite superior de la busqueda

if nargin < 2 || isempty(recLens)
    recLens = [500 1000 2000 5000 10000 20000 40000];
end
ch = '0'; fsMin = 1e6; maxRecords = 1e7;
for k = 1:2:numel(varargin)
    switch lower(varargin{k})
        case 'channel',    ch = varargin{k+1};
        case 'samplerate', fsMin = varargin{k+1};
        case 'maxrecords', maxRecords = varargin{k+1};
    end
end

gAcq  = get(pxi, 'Acquisition');
gVert = get(pxi, 'ConfigurationFunctionsVertical');
gHor  = get(pxi, 'ConfigurationFunctionsHorizontal');
gTrig = get(pxi, 'ConfigurationFunctionsTrigger');
gAct  = get(pxi, 'ConfigurationFunctionsActualValues');
gH    = get(pxi, 'Horizontal');

memTot = get(get(pxi, 'InstrumentCapabilities'), 'Memory_Size');
nCh    = get(get(pxi, 'InherentIVIAttributesDriverCapabilities'), 'Number_of_Channels');
memCh  = memTot / nCh;
fprintf('Memory_Size: %d bytes (%.3f MB) total, %d canales -> %.3f MB por canal\n', ...
        memTot, memTot/2^20, nCh, memCh/2^20);

invoke(gAcq, 'abort');
invoke(gVert, 'configurevertical', ch, 1, 0, 1, 1, 1);
invoke(gTrig, 'configuretriggerimmediate');
set(gH, 'Enable_Records_Memory', 0);

n = numel(recLens);
recLenReal = zeros(1, n);
maxRec     = zeros(1, n);

for i = 1:n
    % Limite inferior que funciona y superior que falla (se duplica hasta fallar)
    lo = 1;
    if ~cabe(recLens(i), lo)
        warning('Ni siquiera cabe 1 registro de %d muestras.', recLens(i));
        continue
    end
    hi = 2;
    while hi <= maxRecords && cabe(recLens(i), hi)
        lo = hi;
        hi = hi * 2;
    end
    if hi > maxRecords
        warning('Mas de %d registros de %d muestras: aumenta MaxRecords.', maxRecords, recLens(i));
        maxRec(i) = lo;
    else
        while hi - lo > 1                    % biseccion
            mid = floor((lo + hi) / 2);
            if cabe(recLens(i), mid), lo = mid; else, hi = mid; end
        end
        maxRec(i) = lo;
    end
    cabe(recLens(i), 1);                     % para leer la longitud real
    recLenReal(i) = invoke(gAct, 'actualrecordlength');
    fprintf('  recLen pedido %6d (real %6d): max %8d registros -> %.1f bytes/registro\n', ...
            recLens(i), recLenReal(i), maxRec(i), memCh / maxRec(i));
end

ok = maxRec > 0;
bpr = memCh ./ maxRec(ok);                   % bytes por registro (cota superior)
c = polyfit(recLenReal(ok), bpr, 1);

cal = struct();
cal.memoryTotal       = memTot;
cal.memoryPerChannel  = memCh;
cal.recLenRequested   = recLens;
cal.recLenActual      = recLenReal;
cal.maxRecords        = maxRec;
cal.bytesPerRecord    = memCh ./ maxRec;
cal.bytesPerSample    = c(1);
cal.overheadPerRecord = c(2);

fprintf('\nAjuste: bytes/registro = %.3f * recLen + %.1f\n', c(1), c(2));
fprintf('  -> bytes por muestra ~ %.2f, sobrecoste por registro ~ %.0f bytes\n', c(1), c(2));

figure('Name', 'Calibracion de memoria');
plot(recLenReal(ok), bpr, 'o', recLenReal(ok), polyval(c, recLenReal(ok)), '-');
xlabel('Longitud real del registro (muestras)'); ylabel('Bytes por registro');
title('Consumo de memoria por registro'); grid on;

    function ok = cabe(rl, nr)
        % true si el driver acepta la configuracion con nr registros de rl muestras
        try
            invoke(gHor, 'configurehorizontaltiming', fsMin, rl, 0, nr, 1);
            invoke(gAcq, 'commit');
            ok = true;
        catch
            ok = false;
        end
    end
end
