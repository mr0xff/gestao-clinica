#!/bin/bash

clear 
echo -e "** Pacientes Mortos :$USER: **\n"
echo -e "\t1. Listar"
echo -e "\t2. Limpar pacientes mortos há mais de duas semanas"

read -p "Escolha: " escolha

case $escolha in
  1)
    for paciente in $(ls $PASTA); do
      echo $paciente | cut -d'.' -f1
    done
    echo
    read -p "Ver detelhes?[s/n]" resposta

    case $resposta in 
      s)
        read -p "Informe o nome do paciente: " paciente
        cat $PASTA/$paciente.txt
        read -p "Enter para continuar..."
      ;;
    esac
  ;;
  2) 
    find $PASTA -type f -mtime +14 -delete
  ;;
  *)
    echo Opção não disponivel!
  ;;
esac
sleep 3