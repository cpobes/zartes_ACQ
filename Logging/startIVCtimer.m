%%%Start IVC Timer

IVCTimer=timer
set(IVCTimer,'period',600)
set(IVCTimer,'executionmode','fixedrate')
set(IVCTimer,'timerfcn','ReadIVCPreassure')

start(IVCTimer)