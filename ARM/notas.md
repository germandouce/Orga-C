## ¿Por que arm?
Porque los procesadores arm son ideales para aplicaciones de baja potencia. Microprocesadores (nebooks, celus)
son dominantes en el mercado de la telefonia movil.

## Ppales caracteristicas
1. Arquitectura Load/Store 
Esto significa q la mayoria de las instrcciones estan basadas en operaciones que se hacen entre registros
Debe llevar los datos a registros para poder operar.
Si no es load Store puedo evitar el uso dew registros

2. Intrucciones de longitud fija

3. Instrucciones de 3 direcciones.
En Intel se podia tener operaciones de 2 registros solamente.
En arm se admiten operaciones entre 3 resgistros. 

3. Todas las intrucciones tienen un espacio para decidir si ejecutarlas o no dependiendo de las condiciones que le demos

4. Instrucciones de Load-Store de Registros multiples.
Permite cargar informacion de y hacia varios registros en una sola operacion.

## Herramientas

- ARMSim
- Editor de texto

### ARMSim

Aplicacion de escritorio para simular la ejecucion de un programa ARM
en un sistema basado eb ARM7TDMI (una version de arm)
Usamos este:
https://gitlab.com/ramiroberruezo/arm-lab 