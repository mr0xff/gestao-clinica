#!/bin/bash

function cadastroPaciente(){
  clear
  echo -e "** Cadastro de Pacientes :$USER: **\n"

  read -p "Nome do paciente: " nome
  read -p "Idade do paciente: " idade

  echo "$nome":$idade >> $ARQUIVO_PACIENTES
  echo -e "Paciente $nome foi cadastrado com sucesso!"
}

clear 
echo -e "** Pacientes :$USER: **\n"

echo -e "\t1. Cadastrar"
echo -e "\t2. Listar"

read -p "Escolha: " escolha

      case $escolha in
  1) 
    cadastroPaciente
  ;;
  2)
    for paciente in $(cat $ARQUIVO_PACIENTES); do
      echo $paciente 
    done
    echo
    read -p "preecione ENTER para continuar..."
  ;;
  *)
    echo Opção não disponivel!
    ;;
esac
sleep 3