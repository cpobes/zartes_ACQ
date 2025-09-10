UPDATE SEPT 2023
Hemos instalado un nuevo disco en el PC e instalado todo, pero al intentar usar el word, sale 'capado' y no se pueden editar los archivos si no se suben a la nube (?!)
Creé una función de prueba BFmanualControlTimer() que crea un timer que actualiza manualmente la W del heater para tratar de controlar la T a una Tset.
Con los PID (0.01,250,0) parece funcionar bien, pero con (0.05,100,0) hay casos en que la W se queda constante aunque T sea diferente de Tset (incluso estando muy por encima).
Veo que es un bug porque sale una W total negativa y el sistema no pone cero, hay que programarlo expresamente para que si W<0, ponga W=0. Además, con el timer funcionando,
intento cambiar el Tset y no funciona porque en Tlast no lee la configuración, sino que usa la que se haya usado inicialmente. Lo cambio y ya funciona. Lo que falta es poder
cambiar en tiempo de ejecución el pid, porque se pasa como estructura al principio al crear el timer y ya no se puede cambiar(*). Hay que hacer un stop, delete y volver a
lanzar la función con el nuevo pid. Lo ideal sería crear una clase para gestionar todo, poder parar y lanzar, reconfigurar, y guardar logs. Además, para gestionar los timers
está la función timerfind(). Aunque se haga clear del timer, sigue en memoria si no se hace delete. Se puede usar stop(timerfind) y delete(timerfind) pero ojo porque eso
para y borra todos.
Por cierto, se puede modificar la función en tiempo de ejecución y el timer usa la versión modificada.
(*) Lo resuelvo leyendo en la funcion del timer el pid de la configuracion del BF en lugar de los valores iniciales y así, si cambio la config en tiempo de ejecución, usa esos
nuevos valores. Funciona! Esto podría permitir una adaptación dinámica del PID.
Pruebo con D=1 y va bien. También pruebo a aumentar el periodo del timer a 30seg y al menos con el pid std de <50mK estabiliza a 40mK. Lo suyo seria hacer un estudio de estabilidad
con transformada Z con el modelo de planta que obtuvimos. Con ese pid, el sistema parece robusto incluso con periodo de 1min. Se empieza a introducir una oscilación de periodo 2min. 
Es estable, diverge o se amortigua? Parece que se amortigua, aunque las fluctuaciones de ruido tardan mas en controlarse. Pongo timer a 1seg (el BF se sigue actualizando cada 5seg)
Funciona pero no responde a la command line, tengo que hacer ctrl+C.
 