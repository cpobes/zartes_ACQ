function pxi=PXI_init(varargin)
%%%función para inicializar una sesión de comunicación con la tarjeta PXI

%makemid('niScope','pxi5922.mdd')
if nargin==0
    device_name='PXI1Slot3';%%%Es el nombre que aparece en el Ni-MAX
else
    device_name=varargin{1};
end

%pxi=icdevice('pxi5922.mdd',device_name);
%connect(pxi)

pxiCards=instrfind('type','IVIInstrument'); %%%OJO! da error si existe ya una tarjeta!!! pq?!

% 30-Sept-2021 no sé que error daba, pero corregido. Version para dejar
% sólo una instancia de la tarjeta PXI.
 switch length(pxiCards)
     case 0
         pxi=icdevice('pxi5922.mdd',device_name);
         connect(pxi)
     case 1
         pxi=pxiCards;
         if (strcmp(pxiCards.Status,'closed')) connect(pxi);end
     otherwise        
         for i=2:length(pxiCards) disconnect(pxiCards(i)); delete(pxiCards(i));end
         pxi=pxiCards(1);
         if (strcmp(pxi.Status,'closed')) connect(pxi);end
 end

