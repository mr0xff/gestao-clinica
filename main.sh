#!/usr/bin/bash

export GRUPOS=(enfermeiros medicos administradores)
export ARQUIVO_FUNCIONARIOS=funcionarios.lst
export ARQUIVO_PACIENTES=pacientes.lst
export ARQUIVO_SERVICOS=servicos.lst
export ARQUIVO_CONSULTAS_MARCADAS=consultas_marcadas.lst
export ARQUIVO_CONSULTAS_ATENDIDAS=consultas_atendidas.lst
export PASTA=pacientes_mortos

function verificarInstacao(){
  grep ${GRUPOS[0]} /etc/group
  if [[ $? -ne 0 ]]; then
    mkdir $PASTA
    echo "configurando o grupo dos funcionários..."
    for grupo in ${GRUPOS[@]}; do
      echo $grupo
      sudo groupadd $grupo
    done
    sleep 3
  fi
}

function menu(){
  verificarInstacao

  clear
  echo -e "*** \033[32;1mSistema de Gestão de Clinicas :$USER: \033[0m***\n"
  
  echo -e "\t1. Funcionário"
  echo -e "\t2. Paciente"
  echo -e "\t3. Serviço"
  echo -e "\t4. Consulta"
  echo -e "\t5. Verificar pacientes mortos"
  echo -e "\t6. Fazer backup dos dados"
  echo -e "\t7. Permissões dos Funcionários"
  echo -e "\t8. Sair\n"
}

while true; do
  menu
  
  read -p "Escolha a opção: " opcao

  case $opcao in 
    1)
      ./funcionario.sh
      ;;
    2)
      ./paciente.sh
      ;;
    3)
      ./servico.sh
      ;;
    4)
      ./consulta.sh
      ;;
    5)
      ./paciente_morto.sh
      ;;
    8)
      echo "volte mais tarde!"
      exit 0
      ;;
    *)
      echo -e "Opção inválida!"
      sleep 2
      ;;
  esac
done
