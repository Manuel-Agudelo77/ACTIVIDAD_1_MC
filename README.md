# ACTIVIDAD_1_MC
Se realiza el calculo del flujo de potencia DC de un sistema de potencia, además se realiza el análisis de contingencias N-1
# <center>**Tarea Nro.1 : Representación matricial de la red**</center>


# <center>*Flujo de carga DC y análisis de contingencias*</center>
<div style="text-align: justify;">
El análisis de flujo de carga es fundamental para evaluar el comportamiento de una red eléctrica bajo diferentes condiciones de operación. Este análisis permite determinar cómo se distribuye la potencia en los nodos y líneas de transmisión, considerando tanto las pérdidas como la capacidad de las líneas. En este proyecto, se realiza un análisis de flujo de carga DC, que es una simplificación del flujo de carga AC. Además, se aborda el análisis de contingencias, que consiste en simular la desconexión de líneas de transmisión y observar su impacto en el sistema. Esto permite identificar las líneas críticas que, al desconectarse, afectan significativamente el comportamiento del sistema. Los resultados obtenidos se representan mediante mapas de calor, lo que facilita la visualización de los efectos de cada contingencia.
</div><br>

En la siguiente imagen se representa el diagrama unifilar de la red.

![Diagrama Unifilar](Unifilar.png)


# <center>**Marco teórico**</center>

## *Matriz Ybus*
<div style="text-align: justify;">
La matriz Ybus es una representación matricial que describe la interacción entre los nodos de un sistema de potencia en términos de admitancia, que es la inversa de la impedancia. Es fundamental para el análisis de redes eléctricas, ya que encapsula toda la información sobre las conexiones de los componentes (generadores, líneas de transmisión, transformadores, etc.) en una red eléctrica.
</div><br>

<div style= "text-align: justify;">
La matriz Ybus es esencial para el cálculo de las corrientes y las tensiones en un sistema de potencia. A través de ella, se puede obtener la relación entre las corrientes y las tensiones en los nodos del sistema. También es clave en el análisis de estabilidad de sistemas de potencia, ya que ayuda a modelar cómo las variaciones en las tensiones afectan el comportamiento dinámico del sistema.
</div><br>

## *Matriz Bbus*

<div style = "text-align: justify">
La matriz Bbus es una matriz derivada de la Ybus que se utiliza específicamente en el análisis de flujo de potencia DC. Mientras que Ybus se utiliza en el análisis de potencia AC, Bbus se emplea cuando se asume que las tensiones en los nodos son constantes en magnitud, y solo se estudian las diferencias de los ángulos de fase entre los nodos. La matriz Bbus en lugar de usar admitancia, utiliza los elementos de susceptancia nodal (parte imaginaria de la admitancia) en el análisis de flujo de potencia DC. Es una forma simplificada de representar la influencia de cada nodo en los demás, considerando solo la reactividad de la red y no la magnitud de las tensiones.
<div><br>

<div style = "text-align: justify">
La matriz Bbus es más eficiente para el análisis DC y el análisis de contingencias, donde se simula la desconexión de líneas para observar su impacto en los flujos de potencia y ángulos de fase.
<div><br>

## *Flujo de Potencia DC*

<div style = "text-align: justify">
 El flujo de potencia en sistemas eléctricos se refiere a cómo la potencia se distribuye entre las distintas partes de una red de transmisión. Existen diferentes métodos para realizar este análisis, y el modelo DC es uno de los más utilizados debido a su simplicidad y eficiencia computacional. En el análisis DC, se hacen varias suposiciones clave:
 <div><br>

<div style = "text-align: justify">
Las tensiones se consideran constantes en magnitud, el sistema es lineal y se asume que las pérdidas por reactancia son despreciables en comparación con las pérdidas resistivas.
Se trabaja con los ángulos de fase de las tensiones para determinar el flujo de potencia, y la relación entre la potencia activa y el ángulo de fase se calcula mediante la matriz Bbus.
 <div><br>

## *Análisis de Contingencias*

<div style = "text-align: justify">
El análisis de contingencias en redes eléctricas implica simular la desconexión de una o varias líneas de transmisión para evaluar su impacto en la estabilidad y la distribución de potencia en el sistema. Este análisis es esencial para identificar las líneas más críticas, es decir, aquellas cuya desconexión provoca una alteración significativa en el comportamiento de la red. Las contingencias pueden clasificarse en contingencias simples (una línea o un componente) o múltiples (varias líneas o componentes). A través de este análisis, se pueden tomar decisiones informadas sobre las mejoras necesarias para fortalecer la red y garantizar su confiabilidad.
 <div><br>

# <center>**Funciones**</center>

La primera función que se realiza es para calcular la matriz Ybus.

*Requiere*


    """
    matriz_Ybus(lines, nodes)

    Calcula la matriz de admitancia Ybus para una red eléctrica utilizando la información de las líneas y nodos.

    ### Entradas:
    - lines: DataFrame que contiene la información de las líneas de transmisión. Debe tener las siguientes columnas:

    - FROM: Nodo de envío de la línea.
    - TO: Nodo de recibo de la línea.
    - R: Resistencia de la línea (en ohmios).
    - X: Reactancia de la línea (en ohmios).
    - B: Susceptancia de la línea (en siemens).
    - TAP: Relación de transformación (valor de tap). Si es 0, no se considera un transformador.

    - nodes: DataFrame que contiene la información de los nodos de la red. Debe tener una fila por nodo con al menos una columna que indique el número de nodo. La cantidad de nodos debe ser coherente con los nodos especificados en `lines`.

    ### Salida:
    - Ybus: Matriz de admitancia Ybus de la red, de tamaño. La matriz contiene los valores de admitancia entre los nodos del sistema, que se utilizarán en el análisis de flujo de potencia y en la simulación de contingencias.

    ### Excepciones:
    - Si algún nodo de las líneas está fuera del rango de nodos disponibles, se lanza un error.
    - Si las líneas tienen resistencia (`R`) y reactancia (`X`) igual a cero, lo que causa una división por cero, se lanza un error.

    ### Requiere:
    - `using LinearAlgebra`
    - `using DataFrames`
    - `using CSV`
    - `using Plots`

    """

La segunda función que se realiza es para calcular la matriz Bbus.

*Requiere*

        """
    matriz_Bbus(lines, nodes)

    Calcula la matriz de susceptancia Bbus para una red eléctrica utilizando la información de las líneas y nodos.

    ### Entradas:
    - lines: DataFrame que contiene la información de las líneas de transmisión. Debe tener las siguientes columnas:
        - FROM: Nodo de envío de la línea.
        - TO: Nodo de recibo de la línea.
        - X: Reactancia de la línea (en ohmios).

    - Nodes: DataFrame que contiene la información de los nodos de la red.

    ### Salida:
    - Bbus: Matriz de susceptancia Bbus de la red, la matriz contiene los valores de susceptancia entre los nodos del sistema, que se utilizarán en el análisis de flujo de potencia y en la simulación de contingencias.

    ### Excepciones:
    - Si la reactancia (`X`) de una línea es cero o inválida, se lanza un error.
    - Si algún nodo de las líneas está fuera del rango de nodos disponibles, se lanza un error.

    ### Requiere:
    - `using LinearAlgebra`
    - `using DataFrames`
    - `using CSV`
    - `using Plots`
    """

La tercera función que se realiza es para calcular el flujo DC del sistema.

*Requiere*

      """
    calcular_FlujoDC(lines, nodes, B_bus)

    Calcula los flujos de potencia en una red eléctrica utilizando el modelo de flujo de potencia DC, basado en la matriz de susceptancia `B_bus` y las condiciones de los nodos y líneas.

    ### Entradas:
    - lines: DataFrame que contiene la información de las líneas de transmisión. Debe tener las siguientes columnas:
        - FROM: Nodo de envío de la línea.
        - TO: Nodo de recibo de la línea.
        - X: Reactancia de la línea (en ohmios).

    - nodes: DataFrame que contiene la información de los nodos de la red. Debe tener al menos las siguientes columnas:
  
    - B_bus: Matriz de susceptancia `B_bus`, obtenida previamente de las líneas de transmisión.

    ### Salida:
    - Flujos (P_lineas): Lista de flujos de potencia en las líneas.
    - θ: Matriz de ángulos nodales de la red.

    ### Excepciones:
    - Si se detectan múltiples nodos slack o ninguno, se lanza un error. Debe existir exactamente un nodo slack en la red.
    - Si el cálculo de las potencias nodales o los flujos no puede realizarse debido a valores no válidos, se lanzará un error.

    ### Requiere:
    - `using LinearAlgebra`
    - `using DataFrames`
    - `using CSV`
    - `using Plots`
    """

La cuarta función que se realiza es para calcular la singularidad de las matrices.

*Requiere*

    """
    Verifica si una matriz cuadrada es no singular (det != 0).
    
    Entrada:
        - Matriz: Matriz cuadrada a evaluar.
    
    Salida:
        - True si la matriz tiene un determinante distinto de cero.
        - False si la matriz es singular o no cuadrada.
    """


La quinta función utilizada es para calcular las contingencias de retirar línea por línea y calcular el flujo de carga DC.

*Requiere*

    """
    Esta función evalúa la contingencia de una red eléctrica, es decir, analiza cómo se comporta el flujo de potencia cuando se elimina una línea de transmisión de la red.

    ### Entradas:
    lines: DataFrame con las líneas de transmisión (cada fila representa una línea con nodos de conexión y parámetros).
    nodes: DataFrame con los nodos del sistema.
    Bbus: Matriz de susceptancia nodal antes de eliminar líneas.

    ###Salidas:
    theta_contingencia: DataFrame con los ángulos nodales después de eliminar cada línea.
    contingencia_Flujos: DataFrame con los flujos de potencia después de eliminar cada línea.
    """

**Licencia**

Programa realizado por: Juan Manuel Agudelo Ocampo

Correo: m.agudelo@utp.edu.co

[![License : CC BY-NC-SA 4.0] (https: img.shields.io/badge/License-CC_BY--NC--SA--4.0-lightgrey)]

