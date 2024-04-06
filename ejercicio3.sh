#!/bin/bash

# Función para imprimir el menú de ayuda
mostrar_uso() {
    echo "Uso: $0 (-h) (-m MODO) (-d FECHA)"
    echo "  -h             Muestra el menú de ayuda"
    echo "  -m MODO        Modo funcionamiento del informe: servidor_web, base_de_datos, proceso_batch, aplicación, monitoreo"
    echo "  -d FECHA       Fecha en formato año-mes-día"
}


# Función para generar el informe
informe() {
    local modo="$1"    # Modo especificado
    local fecha="$2"   # Fecha especificada
    local log_archivo="$PWD/logs.txt"  # Archivo de registro

    # Verificar si se especificó el modo y la fecha
    if [ -n "$modo" ] && [ -z "$fecha" ]; then
        # Generar informe para el modo especificado en todas las fechas
        awk -v mode="$modo" '$5 == mode' "$log_archivo"
    elif [ -n "$modo" ] && [ -n "$fecha" ]; then
        # Generar informe para el modo y la fecha especificados
        awk -v mode="$modo" -v date="$fecha" '$1 == "[" date && $5 == mode' "$log_archivo"
    elif [ -z "$modo" ] && [ -n "$fecha" ]; then
        # Generar informe para la fecha especificada, sin importar el modo
        awk -v date="$fecha" '$1 == "[" date' "$log_archivo"
    else
        echo "Error: Se debe especificar al menos una opción: -m o -d." >&2
        exit 1
    fi
    
}

# Manejar opciones de línea de comandos
while getopts ":hm:d:" opcion; do
    case $opcion in
        h)
            # Mostrar el menú de ayuda y salir
            mostrar_uso
            exit
            ;;
        m)
            # Asignar el modo especificado a la variable "modo"
            modo="$OPTARG"
            ;;
        d)
            # Asignar la fecha especificada a la variable "fecha"
            fecha="$OPTARG"
            ;;
        \?)
            # Opción inválida: mostrar mensaje de error y salir
            echo "Opción inválida: -$OPTARG" >&2
            exit 1
            ;;
        :)
            # Opción requiere un argumento: mostrar mensaje de error y salir
            echo "La opción -$OPTARG necesita un argumento." >&2
            exit 1
            ;;
    esac
done

# Shift para omitir las opciones procesadas
shift $((OPTIND - 1))
log_archivo="$1"

# Generar el informe
informe "$modo" "$fecha" "$log_archivo"