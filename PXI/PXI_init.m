function pxi=PXI_init()
%%%funci�n para inicializar una sesi�n de comunicaci�n con la tarjeta PXI

%makemid('niScope','pxi5922.mdd')
device_name='PXI1Slot3';%%%Es el nombre que aparece en el Ni-MAX

        pxi=icdevice('pxi5922.mdd',device_name);
        connect(pxi)

% pxi=instrfind('type','IVIInstrument'); %%%OJO! da error!!! pq?!
% 
% switch length(pxi)
%     case 0
%         pxi=icdevice('pxi5922.mdd',device_name);
%         connect(pxi)
%     case 1
%         if (strcmp(pxi.Status,'closed')) fopen(pxi);end
%     otherwise        
%         for i=2:length(pxi) delete(pxi(i));end
%         pxi=pxi(1);
%         if (strcmp(pxi.Status,'closed')) fopen(pxi);end
% end

