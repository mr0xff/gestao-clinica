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
export NOME_PARTICAO=disco_backup.iso

function configurarNFS(){
  # referencia para configuração https://ubuntu.com/server/docs/network-file-system-nfs
  sudo apt install nfs-kernel-server
  sudo systemctl start nfs-kernel-server.service
  sleep 3
  sudo mkdir /gestao_clinica
  sudo vi /etc/exports
  sudo exportfs -a 
}

function verificarInstacao(){
  grep ${GRUPOS[0]} /etc/group
  if [[ $? -ne 0 ]]; then
    echo "configurando o grupo dos funcionários..."
    for grupo in ${GRUPOS[@]}; do
      echo criando o grupo dos $grupo
      sudo groupadd $grupo
    done
    mkdir $PASTA logs/ $PASTA_BACKUP
    sudo ./auto_backup.sh &
    configurarNFS

    # configuração das permissões dos dados 

    sudo touch $ARQUIVO_FUNCIONARIOS
    sudo chown :administradores $ARQUIVO_FUNCIONARIOS
    sudo chmod o=r $ARQUIVO_FUNCIONARIOS

    sudo touch $ARQUIVO_PACIENTES
    sudo chown :medicos $ARQUIVO_PACIENTES
    
    sudo touch $ARQUIVO_SERVICOS
    sudo chown :medicos $ARQUIVO_SERVICOS

    sudo touch $ARQUIVO_CONSULTAS_MARCADAS
    sudo chown :medicos $ARQUIVO_CONSULTAS_MARCADAS
    
    sudo touch $ARQUIVO_CONSULTAS_ATENDIDAS
    sudo chown :medicos $ARQUIVO_CONSULTAS_ATENDIDAS
    sudo chmod 660 $ARQUIVO_CONSULTAS_ATENDIDAS
    
    #sudo chown -R :medicos $PASTA
    #sudo chmod 660 $ARQUIVO_CONSULTAS_ATENDIDAS

    # configuração das permissões dos scripts 

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
  echo -e "\t7. Ver logs do sistema"
  echo -e "\t0. Sair\n"
  echo -e "\treset. Para repor o sistema"
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
      sudo ./backup.sh
      if [[ ! $! ]]; then
        echo $! >> $LOGS_SISTEMA
        sudo ./auto_backup.sh &
      fi
      ;;
    7)
      less $LOGS_SISTEMA
      ;;
    reset)
        read -p "Tem certeza que deseja resetar o sistema [s/n]?" resposta
        
        if [[ $resposta != "s" ]]; then
          sleep 2
        else
          for grupo in ${GRUPOS[*]}; do 
            sudo groupdel $grupo
          done

          for funcionario in $(cat $ARQUIVO_FUNCIONARIOS); do
            sudo userdel $funcionario
          done

          sudo echo > $ARQUIVO_FUNCIONARIOS
          sudo echo > $ARQUIVO_PACIENTES
          sudo echo > $ARQUIVO_SERVICOS
          sudo echo > $ARQUIVO_CONSULTAS_MARCADAS
          sudo echo > $ARQUIVO_CONSULTAS_ATENDIDAS
          sudo echo > $LOGS_SISTEMA
          rm -rf $PASTA/* $PASTA_BACKUP/*
          echo "Sistema reposto com sucesso!" 
          read -p "Precione Enter para continuar ..."
        fi
        exit 0
      ;;
    0)
      echo "bye :)!"
      exit 0
      ;;
    *)
      echo -e "Opção inválida!"
      sleep 2
      ;;
  esac
done
