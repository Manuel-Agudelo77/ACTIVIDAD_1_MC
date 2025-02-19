using LinearAlgebra
using DataFrames
using CSV
using Plots
using SparseArrays

# Calcular la matriz de admitancia nodal

function matriz_Ybus(lines, nodes)
    """
    Entradas:   lines: DataFrames
                nodes : DataFrames
    Salida :    Ybus : matriz
    """
    total_nodes = nrow(nodes) # Número total de nodos
    total_lines = nrow(lines) # Número total de filas
    Ybus = zeros(ComplexF64, total_nodes, total_nodes)

    for k = 1:total_lines
        n1 = lines.FROM[k] # Nodo de envío n1
        n2 = lines.TO[k]  # Nodo de recibo n2
        # Verificar que los nodos están dentro del rango
        if n1 > total_nodes || n2 > total_nodes || n1 < 1 || n2 < 1
        error("El nodo $n1 o $n2 está fuera del rango de nodos disponibles.")
        end
        # Admitancia de la línea (evitando división por cero)
        if lines.R[k] == 0 && lines.X[k] == 0
            error("La línea $k tiene R y X igual a cero, lo que causa una división por cero.")
        end
        yL = 1/(lines.R[k]+lines.X[k]*1im)
        # Susceptancia de la línea
        Bs = lines.B[k]*1im/2
        # Valor del TAP
        t = lines.TAP[k]
        if lines.TAP[k] == 0
            Ybus[n1,n1] += yL + Bs   # Dentro de la diagonal
            Ybus[n1,n2] -= yL        # Fuera de la diagonal
            Ybus[n2,n1] -= yL        # Fuera de la diagonal
            Ybus[n2,n2] += yL + Bs   # Dentro de la diagonal
        else
            Ybus[n1,n1] += (t^2 - t)*yL  # Dentro de la diagonal
            Ybus[n1,n2] -= t*yL          # Fuera de la diagonal
            Ybus[n2,n1] -= t*yL          # Fuera de la diagonal
            Ybus[n2,n2] += (1-t)*yL      # Dentro de la diagonal
        end
    end
    return Ybus
end

## Función principal
lines = DataFrame(CSV.File("ACTIDAD_1_Flujo_de_Carga/Actividad 1/lines.csv"))
nodes = DataFrame(CSV.File("ACTIDAD_1_Flujo_de_Carga/Actividad 1/nodes.csv"))
Ybus = matriz_Ybus(lines, nodes)

# Se calcula la matriz Bbus

function matriz_Bbus(lines,nodes)
    """
    Entradas:   lines: DataFrames
                nodes : DataFrames
    Salida :    Bbus : matriz
    """
    total_nodes = nrow(nodes)
    total_lines = nrow(lines)
    Bbus = zeros(total_nodes, total_nodes)

    for k = 1:total_lines
        # Nodo de envío
        n1 = lines.FROM[k]
        # Nodo de recibo
        n2 = lines.TO[k]
        # Susceptancia
        BL = 1/(lines.X[k])
        # Evitar errores por división entre cero
        if isinf(BL) || isnan(BL)
            error("Reactancia X en la línea $k es cero o inválida.")
        end
        Bbus[n1,n1] += BL        # Dentro de la diagonal
        Bbus[n1,n2] -= BL        # Fuera de la diagonal
        Bbus[n2,n1] -= BL        # Fuera de la diagonal
        Bbus[n2,n2] += BL        # Dentro de la diagonal
    end
    return Bbus
end

function calcular_FlujoDC(lines, nodes, B_bus)
    """
    Entradas:   lines: DataFrames
                nodes : DataFrames
    Salida :    P_km (P_lineas) : lista de flujos
                θ : matriz
    """
    total_nodes = nrow(nodes)
    total_lines = nrow(lines)

    # Identificando el nodo slack
    s = nodes[nodes.TYPE .== 3, "NUMBER"]
    if length(s) > 1
        error("Se detectaron múltiples nodos slack. Solo debe haber uno.")
    elseif length(s) == 0
        error("No se encontró ningún nodo slack.")
    end
    s = s[1]  # Asegurar que s es un número, no un vector
    # Elimino fila y columna del nodo slack
    B_bus = B_bus[setdiff(1:total_nodes, s), setdiff(1:total_nodes, s)] 
    # Calculo de las potencias nodales
    Pn = nodes.PGEN .- nodes.PLOAD
    # Eliminando el nodo slack (Tipo 3)
    Pn = Pn[1:end .!= s]
    # Angulos nodales
    theta_ = inv(B_bus) * Pn
    # Vector θ completo (slack = 0)
    theta = zeros(nrow(nodes))
    theta[1:end .!= s] = theta_
    # Vector de flujos
    flujos = zeros(nrow(lines))
    # Se calculan las potencias de línea
    for i in 1:nrow(lines)
        from = lines.FROM[i]
        to = lines.TO[i]
        B = 1/lines.X[i]
        flujos[i] = B*(theta[from] - theta[to])
    end
    return flujos, theta

end
Bbus = matriz_Bbus(lines, nodes)
theta_df, flujos_df = calcular_FlujoDC(lines, nodes, Bbus)

function tiene_determinante(matriz)
    """
    Verifica si una matriz cuadrada es no singular (det != 0).
    
    Entrada:
        - Matriz: Matriz cuadrada a evaluar.
    
    Salida:
        - True si la matriz tiene un determinante distinto de cero.
        - False si la matriz es singular o no cuadrada.
    """
    # Verifica si la matriz es cuadrada
    if size(matriz, 1) != size(matriz, 2)
        return false
    end

    det_valor = det(matriz)
    return !isapprox(det_valor, 0, atol=1e-18)
end

function contingencia(lines, nodes, Bbus)
    """
    Esta función evalúa la contingencia de una red eléctrica, 
    es decir, analiza cómo se comporta el flujo de potencia
    cuando se elimina una línea de transmisión de la red.

    Entradas:
    lines: DataFrame con las líneas de transmisión (cada fila representa una línea con nodos de conexión y parámetros).
    nodes: DataFrame con los nodos del sistema.
    Bbus: Matriz de susceptancia nodal antes de eliminar líneas.
    Salidas:
    theta_contingencia: DataFrame con los ángulos nodales después de eliminar cada línea.
    contingencia_Flujos: DataFrame con los flujos de potencia después de eliminar cada línea.
    """
    total_lines = nrow(lines)
    total_nodes = nrow(nodes)
    contingencia_theta = DataFrame()
    contingencia_Flujos = DataFrame()
    for line = 1:total_lines
        matriz_copiaBbus = copy(Bbus) # Se crea una copia de la B_bus para no alterar la original
        n1, n2 = lines.FROM[line], lines.TO[line] # Nodo de envio y Nodo de recibo
        # Susceptancia - Se quita el aporte de la línea a la matriz Susceptancia
        Suscep = 1/(lines.X[line])
        matriz_copiaBbus[n1,n1] -= Suscep  # Dentro de la diagonal
        matriz_copiaBbus[n1,n2] += Suscep  # Fuera de la diagonal
        matriz_copiaBbus[n2,n1] += Suscep  # Fuera de la diagonal
        matriz_copiaBbus[n2,n2] -= Suscep  # Dentro de la diagonal

        # Debo modificar la matriz Bbus para que tenga determinante
        matriz_Sinslack = copy(matriz_copiaBbus)
        s = nodes[nodes.TYPE .== 3, "NUMBER"]  # Identifico nodo Slack
        matriz_Sinslack = matriz_Sinslack[setdiff(1:end, s), setdiff(1:end, s)] # Elimino la fila y columna de Slack
        # Hallar determinante
        if !tiene_determinante(matriz_Sinslack)
            flujos = fill(Inf64, total_lines) # Vector de flujos
            theta = fill(Inf64, total_nodes)  # Vector de ángulos
        else 
            flujos, theta = calcular_FlujoDC(lines, nodes, matriz_copiaBbus)
        end
        # Se fuerza el flujo en la línea eliminada a cero, ya que se supone que está desconectada.
        flujos[line] = 0
        # Detecta si la línea actual es paralela a la anterior (misma conexión entre nodos consecutivos).
        # Identificamos cuántas líneas existen entre los mismos nodos
        paralelo = sum((lines.FROM .== n1) .& (lines.TO .== n2)) > 1

        if paralelo
            col_theta = "Angulos caso línea $(n1) - $(n2) paralela"
            contingencia_theta[!, col_theta] = theta
            col_flujos = "Flujos caso línea $(n1) - $(n2) paralela"
            contingencia_Flujos[!, col_flujos] = flujos
        else
            col_theta = "Angulos caso línea $(n1) - $(n2)"
            contingencia_theta[!, col_theta] = theta
            col_flujos = "Flujos caso línea $(n1) - $(n2)"
            contingencia_Flujos[!, col_flujos] = flujos
        end

    end
    return contingencia_theta, contingencia_Flujos
end

theta,flujos = contingencia(lines, nodes, Bbus) 

CSV.write("ACTIDAD_1_Flujo_de_Carga/Actividad 1/flujos_potencia_contingencias.csv", flujos)
CSV.write("ACTIDAD_1_Flujo_de_Carga/Actividad 1/angulos_nodales_contingencias.csv", theta)

# Graficando los datos para mayor legibilidad
# Leer datos

data_theta = CSV.read("ACTIDAD_1_Flujo_de_Carga/Actividad 1/angulos_nodales_contingencias.csv", DataFrame)
data_flujos = CSV.read("ACTIDAD_1_Flujo_de_Carga/Actividad 1/flujos_potencia_contingencias.csv",DataFrame)


# Convertir el DataFrame a una matriz
matriz_theta = Matrix(data_theta)
matriz_flujos = Matrix(data_flujos)

# Creando el mapa de calor para los angulos
p1 = heatmap(
    matriz_theta,
    c=:plasma,
    aspect_ratio=:equal,
    xlabel="Casos",
    ylabel="Nodo",
    title="Angulos para las contingencias n-1"
)

# Creando el mapa de calor para los flujos
p2 = heatmap(
    matriz_flujos,
    c=:plasma,
    aspect_ratio=:equal,
    xlabel="Casos",
    ylabel="Lineas",
    title="Flujos de potencia para las lineas"
)

# Combinar los plots
plot(p1, p2, layout=(1,2), size=(1200,500))


