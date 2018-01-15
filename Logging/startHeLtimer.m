%%%Start HeL Timer

Ltimer=timer
set(Ltimer,'timerfcn','ReadHeLevel')
set(Ltimer,'executionmode','fixedrate')
set(Ltimer,'period',600)
start(Ltimer)