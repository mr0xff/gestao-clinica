#!/bin/bash

clear 
echo -e "** Pacientes Mortos :$USER: **\n"
echo -e "\t1. Listar"
echo -e "\t2. Limpar pacientes mortos"

read -p "Escolha: " escolha

case $escolha in
  1)
    for paciente in $(ls $PASTA); do
      echo $paciente 
    done
    echo
    read -p "preecione ENTER para continuar..."
  ;;
  2) 
    find $PASTA -type f -mtime +14 -delete
  ;;
  *)
    echo Opção não disponivel!
  ;;
esac
sleep 3