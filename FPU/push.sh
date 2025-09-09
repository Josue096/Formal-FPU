#!/bin/bash

# Este es un comando para ejecutar de manera rapida la carga de archivos a Git, añade todos los cambios o archivos añadidos

# Si no se pasa ningún argumento, usa "commit" como comentario por defecto al git
if [ $# -eq 0 ]; then
  comentario="commit"
else
  # Combina todos los argumentos en una sola cadena como comentario
  comentario="$*"
fi

# Ejecuta los comandos de Git
git add .
git commit -m "$comentario"
git push
