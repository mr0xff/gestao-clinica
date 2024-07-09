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
export NOME_PARTICAO=/dev/sda3
export DIRETORIO_NFS=/opt/msg # compartilhamento das variaveis entre os script

function configurarNFS(){
  # referencia para configuração https://ubuntu.com/server/docs/network-file-system-nfs
  sudo apt install nfs-kernel-server nfs-common # instalação do nfs 
  sudo systemctl start nfs-kernel-server.service # inicialização do nfs
  sleep 3
  sudo mkdir /mensagem # diretorio de partilha de mensagens
  sudo chmod -R 777 /mensagem
  clear
  echo -e "configure o arquivo /etc/exports incluindo o directorio \033[31;1m/mensagem *(rw,sync,subtree_check)\033[0m"
  sudo exportfs -a 
  read -p "Enter para continuar ..."
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
    sudo chown :medicos pacientes_mortos
    
    sudo touch $ARQUIVO_SERVICOS
    sudo chown :medicos $ARQUIVO_SERVICOS

    sudo touch $ARQUIVO_CONSULTAS_MARCADAS
    sudo chown :medicos $ARQUIVO_CONSULTAS_MARCADAS
    
    sudo touch $ARQUIVO_CONSULTAS_ATENDIDAS
    sudo chown :medicos $ARQUIVO_CONSULTAS_ATENDIDAS
    sudo chmod 660 $ARQUIVO_CONSULTAS_ATENDIDAS
    sudo chmod 777 . 
    sudo chmod 777 *.lst
    sudo chmod 666 $LOGS_SISTEMA

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
  echo -e "\t8. Ver backup existentes"
  echo -e "\t\033[31;1m9\033[0m. Mudar para outro funcionario"
  echo -e "\t10. Enviar mensagem a uma filial"
  echo -e "\n\t0. Sair\n"
  echo -e "\treset. Para repor o sistema"
}

while true; do
  menu
  
  read -p "Escolha a opção: " opcao

  case $opcao in 
    1)
      groups | grep sudo > /dev/null # verifica se o usuario é administrador

      if [[ $? -ne 0 ]]; then 
        echo Apenas administradores do sistema
        sleep 3
      else
        ./funcionario.sh
      fi
      ;;
    2)
      ./paciente.sh
      ;;
    3)
      groups | grep sudo > /dev/null # verifica se o usuario é administrador

      if [[ $? -ne 0 ]]; then 
        echo Apenas administradores do sistema
        sleep 3
      else
        ./servico.sh
      fi
      ;;
    4)
      ./consulta.sh
      ;;
    5)
      groups | grep ${GRUPOS[1]} > /dev/null # verifica se o usuario é administrador

      if [[ $? -ne 0 ]]; then 
        echo Apenas medicos do sistema
        sleep 3
      else
        ./paciente_morto.sh
      fi
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
    8)
      ls -l copias_seguranca/ | awk -F' ' '{print $9}'

      echo
      echo Total de backups: $(ls copias_seguranca/ | wc -l)
      read -p "Enter para continuar..."
      ;;
    9)
      for user in $(cat $ARQUIVO_FUNCIONARIOS); do
      if [[ $? -eq 0 ]]; then
        echo $user | tr : '\t'
      fi
    done
      echo
      read -p "Escolha o nome da conta [cancelar]: " funcionario

      if [[ $funcionario!="cancelar" ]];then
        echo logando como $funcionario
        su -c ./inicial.sh $funcionario
      fi
    ;;
    10)
      clear 
      apt list nfs-common | grep common &>/dev/null # verficação se o nfs está instalado

      if [[ $? -ne 0 ]]; then 
        echo "Não tem o nfs instalado, precisa de internet para a instalação"
        sudo apt install -y nfs-common > /dev/null
        if [[ $? -ne 0 ]]; then
          echo Falha na instalação!
          exit -1
        fi
        echo instalação feita com sucesso!
      else
        if [[ ! -d $DIRETORIO_NFS ]]; then # verifica a existencia do diretorio
          sudo mkdir $DIRETORIO_NFS &> /dev/null
        fi
        read -p "Escreva o ip do servidor nfs da filial de destino: " ipFilial
        sudo mount -t nfs4 $ipFilial:/mensagem $DIRETORIO_NFS # montagem do diretorio remoto via nfs
        if [[ $? -ne 0 ]]; then 
          echo Falha na montagem 
          exit -1
        fi

        while true; do 
          clear
          echo -e "\t *** Chat ***\n"
          cat $DIRETORIO_NFS/chat.log
          echo
          read -p "Mensagem [s - Sair]: " mensagem 

          case $mensagem in 
            s)
              echo bye!
              sudo umount $DIRETORIO_NFS
              break
              exit 0
            ;;
          esac
          echo $mensagem >> $DIRETORIO_NFS/chat.log
        done
      fi

      read -p "Enter para continuar ..."
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
            usuario=$(echo $funcionario  | cut -d: -f1) 
            sudo userdel $usuario
          done

          sudo killall -9 auto_backup.sh
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
