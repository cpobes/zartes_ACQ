function I=k220_readI(k220)
%%%%funcion para leer el valor de I y poder volver a usarlo.

x=query(k220,'*idn?\n');%%%query general que devuelve todo.
%%%NDCI+xxxx,V....
xx=regexp(x,'.DCI([^,]*),','tokens');
I=str2num(xx{1}{1});