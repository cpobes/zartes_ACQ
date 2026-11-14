%%%INIT PATHS SCRIPT

restoredefaultpath

% Lista de carpetas raíz (cada una se añade junto con TODAS sus subcarpetas)
carpetas = {
    %'C:\Users\Ana\MatlabCode'
    'C:\Users\nico\Documents\GitHub\Zartes_AnaSoft'
    'C:\Users\nico\Desktop\Software\Zartes_Soft_Acq'
    };

for k = 1:numel(carpetas)
    if exist(carpetas{k}, 'dir')
        addpath(genpath(carpetas{k}));
    else
        warning('Carpeta no encontrada: %s', carpetas{k});
    end
end

clear carpetas k