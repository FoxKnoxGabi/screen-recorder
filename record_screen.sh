#!/bin/bash

# Configuración
OUTPUT_DIR="$HOME/Videos"
FILENAME="$(date +"%Y-%m-%d_%H-%M-%S.mp4")"
OUTPUT_PATH="$OUTPUT_DIR/$FILENAME"
LOCKFILE="/tmp/screen-recorder.lock"

start_recording() {
    # Seleccionar región o pantalla completa
    if [ "$1" = "-f" ]; then
        wf-recorder -f "$OUTPUT_PATH" -a &
    else
        region=$(slurp) || exit 1  # Si el usuario cancela, no inicia grabación
        wf-recorder -g "$region" -f "$OUTPUT_PATH" -a &
    fi

    PID=$!
    echo "$PID" > "$LOCKFILE"
    notify-send --app-name="Grabacion" "Grabando..." -t 2000
}

stop_recording() {
    PID=$(cat "$LOCKFILE")
    kill -SIGINT "$PID"
    rm -f "$LOCKFILE"
    notify-send --app-name="Grabacion" "Guardado en: $OUTPUT_PATH" -i "video-x-generic" \
        --action="open=Abrir video" --action="show=Mostrar en carpeta"

}

toggle_recording() {
    if [ -f "$LOCKFILE" ]; then  # Si hay grabación en curso, detenerla
        stop_recording
    else  # Si no hay grabación, iniciar una nueva
        start_recording "$1"
    fi
}

# Crear carpeta si no existe
mkdir -p "$OUTPUT_DIR"

# Ejecutar lógica principal (toggle)
toggle_recording "$1"  # Pasar "-f" como argumento para grabar pantalla completa
