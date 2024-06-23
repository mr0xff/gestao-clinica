#!/usr/bin/bash

export GRUPOS=(enfermeiros medicos administradores)
export ARQUIVO_FUNCIONARIOS=funcionarios.lst
export ARQUIVO_PACIENTES=pacientes.lst
export ARQUIVO_SERVICOS=servicos.lst
export ARQUIVO_CONSULTAS_MARCADAS=consultas_marcadas.lst
export ARQUIVO_CONSULTAS_ATENDIDAS=consultas_atendidas.lst
export PASTA=pacientes_mortos
export LOGS_SISTEMA=logs/eventos_sistema.log
export PASTA_BACKUP=copias_seguranca/
export NOME_PARTICAO=/tmp/exemplo.dd

function configurarNFS(){
  # referencia para configuração https://ubuntu.com/server/docs/network-file-system-nfs
  sudo apt install nfs-kernel-server
  sudo systemctl start nfs-kernel-server.service
  sudo mkdir /sistema_clinica
  echo -e "/sistema_clinica *(ro,sync,subtree_check)" >> /etc/exports
  sudo exportfs -a 
}

function verificarInstacao(){
  grep ${GRUPOS[0]} /etc/group
  if [[ $? -ne 0 ]]; then
    mkdir $PASTA logs/ $PASTA_BACKUP
    sudo ./auto_backup.sh &
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
  echo -e "\t7. Sair\n"
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
    6)
      ./backup.sh
      ;;
    7)
      echo "volte mais tarde!"
      exit 0
      ;;
    *)
      echo -e "Opção inválida!"
      sleep 2
      ;;
  esac
done
