function pxi=PXI_init()
%%%funci�n para inicializar una sesi�n de comunicaci�n con la tarjeta PXI

%makemid('niScope','pxi5922.mdd')
device_name='PXI1Slot3_3';%%%Es el nombre que aparece en el Ni-MAX
pxi=icdevice('pxi5922.mdd',device_name)
connect(pxi)
