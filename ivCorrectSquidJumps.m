function [dataCorr, info] = ivCorrectSquidJumps(data, Rf, invMf, opts)
% IVCORRECTSQUIDJUMPS  Corrige los saltos de SQUID de una IV recién adquirida.
%
%   [dataCorr, info] = ivCorrectSquidJumps(data, Rf, invMf)
%   [dataCorr, info] = ivCorrectSquidJumps(data, Rf, circuit)      % circuit.invMf
%
% data   matriz de acquireIVs: [t, Ibias (uA), 0, Vout (V)] (o [Ibias, Vout])
% Rf     resistencia de realimentación del FLL en ohmios (p. ej. opt.Rf = 3e3)
% invMf  1/Mf en uA/Phi0 (circuit.invMf). El salto de Vout por cuanto de flujo
%        es q = Rf*invMf*1e-6 V. Con invMf = [] solo se centra.
%
% dataCorr  igual que data pero con Vout (última columna) SIN SALTOS y sin
%           centrar, para seguir con corregir1rama como siempre. Si la
%           corrección falla, dataCorr = data.
% info      .status 'clean' | 'corrected' | 'partial' | 'bad' | 'error'
%           .jumps  [índice, cuantos] de cada salto corregido (índice desde 1)
%           .flags, .messages, .q_V, .mS_V_per_uA, .voff_V
%           .valid  puntos válidos (no saturados ni congelados)
%           .vcent  Vout sin saltos y centrado (NaN en los no válidos)
%
% Usa la corrección de Python (python/zartes/ivcurve.py, la misma que
% tools/iv_correct.py aplica por lotes) a través de tools/iv_correct_one.py.
% Python: opts.python, o el que recuerde getpref('zartes','python') (lo fija
% zartes_init_cooldown), o 'python'. Solo necesita numpy.
%
% En acquireIVs, justo antes de IV=corregir1rama(data):
%     [dataC, ivinfo] = ivCorrectSquidJumps(data, Rf_ohm, circuit.invMf);
%     fprintf('IV: %s, %d saltos corregidos\n', ivinfo.status, size(ivinfo.jumps,1));
%     if any(strcmp(ivinfo.status, {'corrected','clean','partial'})), data = dataC; end
% y guardar, si se quiere, el original y el corregido (el original con
% save(outfile,'data','-ascii') ANTES de sustituir data).

if nargin < 4, opts = struct(); end
if isstruct(invMf), invMf = invMf.invMf; end
py = 'python';
if ispref('zartes', 'python'), py = getpref('zartes', 'python'); end
if isfield(opts, 'python'), py = opts.python; end
vsat = 9; if isfield(opts, 'vsat'), vsat = opts.vsat; end

dataCorr = data;
info = struct('status', 'error', 'jumps', zeros(0, 2), 'flags', {{}}, 'messages', {{}}, ...
              'q_V', NaN, 'mS_V_per_uA', NaN, 'voff_V', NaN, 'valid', true(size(data, 1), 1), ...
              'vcent', nan(size(data, 1), 1));
here = fileparts(mfilename('fullpath'));
script = fullfile(here, '..', '..', 'tools', 'iv_correct_one.py');
fin = [tempname '.txt'];
fout = [tempname '.json'];
cleanup = onCleanup(@() delfiles(fin, fout));
dlmwrite(fin, data, 'delimiter', ' ', 'precision', 12);
cmd = sprintf('"%s" "%s" "%s" --rf %.10g --vsat %g --out "%s"', py, script, fin, Rf, vsat, fout);
if ~isempty(invMf), cmd = sprintf('%s --inv-mf %.10g', cmd, invMf); end
[st, msg] = system(cmd);
if st ~= 0 || ~exist(fout, 'file')
    info.messages = {sprintf('no se pudo ejecutar Python (%d): %s', st, msg)};
    warning('ivCorrectSquidJumps:python', '%s', info.messages{1});
    return
end
fid = fopen(fout, 'r'); txt = fread(fid, '*char')'; fclose(fid);
if exist('jsondecode', 'builtin') || exist('jsondecode', 'file')
    r = jsondecode(txt);
else
    r = loadjson(txt);                 % jsonlab en MATLAB antiguos
end
info.status = r.status;
info.messages = tocell(getfield_def(r, 'messages', {}));
if ~r.ok
    warning('ivCorrectSquidJumps:error', '%s', strjoin(info.messages, ' | '));
    return
end
info.flags = tocell(r.flags);
info.q_V = r.q_V;
info.mS_V_per_uA = num_or_nan(r.mS_V_per_uA);
info.voff_V = num_or_nan(r.voff_V);
info.valid = logical(tovec(r.valid));
info.vcent = tovec(r.v_cent);
J = r.jumps;
if iscell(J)                          % [[i, n, rama], ...] con texto: celdas
    info.jumps = zeros(numel(J), 2);
    for k = 1:numel(J)
        info.jumps(k, :) = [double(J{k}{1}) double(J{k}{2})];
    end
end
vcorr = tovec(r.v_corr);
if numel(vcorr) == size(data, 1) && ~strcmp(r.status, 'bad')
    dataCorr(:, end) = vcorr;
end
end

function v = tovec(x)
if iscell(x)
    v = nan(numel(x), 1);
    for k = 1:numel(x)
        if ~isempty(x{k}), v(k) = double(x{k}); end
    end
else
    v = double(x(:));
end
end

function c = tocell(x)
if ischar(x), c = {x}; elseif iscell(x), c = x(:)'; else, c = {}; end
end

function v = getfield_def(s, f, d)
if isfield(s, f), v = s.(f); else, v = d; end
end

function v = num_or_nan(x)
if isempty(x), v = NaN; else, v = double(x); end
end

function delfiles(varargin)
for k = 1:numel(varargin)
    if exist(varargin{k}, 'file'), delete(varargin{k}); end
end
end
