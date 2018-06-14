function pxi_AbortAcquisition(pxi)
%%%%Si una acq queda colgada da error ejecutar otra acq y hay que abortar
%%%%antes.

invoke(pxi.Acquisition, 'abort'); 