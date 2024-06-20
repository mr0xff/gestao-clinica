#!/usr/bin/bash

# ola mundo do bash

GRUPOS=(enfermeiros medicos administradores)
ARQUIVO_FUNCIONARIOS=funcionarios.lst
ARQUIVO_PACIENTES=pacientes.lst
ARQUIVO_SERVICOS=servicos.lst
ARQUIVO_CONSULTAS_MARCADAS=consultas_marcadas.lst

function verificarInstacao(){
  grep ${GRUPOS[0]} /etc/group
  if [[ $? -ne 0 ]]; then
    echo "configurando o grupo dos funcionários..."
    for grupo in ${GRUPOS[@]}; do
      echo $grupo
      sudo groupadd $grupo
    done
    sleep 3
  fi
}

function cadastroServico(){
	clear
  echo -e "** Cadastro de Serviços :$USER: **\n"

  read -p "Nome do serviço: " servico
  read -p "Preço do serviço: " preco

  echo "$servico":$preco >> $ARQUIVO_SERVICOS
  echo -e "Serviço $servico foi cadastrado com sucesso!"
	
}

function cadastroConsulta(){
	clear
  echo -e "** Marcação de Consultas :$USER: **\n"
	
	grep medicos /etc/group
  read -p "Informe o Nome do Medico: " medico
  echo 
 	
  for servico in `cat $ARQUIVO_PACIENTES`;
  do
  	echo $servico
  done
  
  read -p "Informe o nome do paciente: " paciente
  echo
  
  indice=1
  for servico in `cat $ARQUIVO_SERVICOS`;
  do
  	echo $indice. $servico
  	indice=$(($indice + 1))
  done
  
  read -p "Escolha o serviço: " servico
  
  read -p "Informe a Hora da consulta: " hora
  read -p "Informe a prioridade da consulta: " prioridade
  

  echo "$medico:$paciente:$hora:$prioridade" >> $ARQUIVO_CONSULTAS_MARCADAS
  echo -e "Consulta marcada com sucesso!"
}

function cadastroPaciente(){
  clear
  echo -e "** Cadastro de Pacientes :$USER: **\n"

  read -p "Nome do paciente: " nome
  read -p "Idade do paciente: " idade

  echo "$nome":$idade >> $ARQUIVO_PACIENTES
  echo -e "Paciente $nome foi cadastrado com sucesso!"
}

function cadastroFuncionario(){
  clear
  echo -e "** Cadastro de Funcionário :$USER: **\n"
  grep ${GRUPOS[2]} /etc/group | grep $USER >/dev/null

  if [[ $? -ne 0 ]]; then
    sudo usermod -aG ${GRUPOS[2]} $USER # adiciona a conta actuamente logada ao nível mais alto
    echo "Olá $USER, voce foi adicionado ao grupo ${GRUPOS[2]}"
  else
    read -p "Informe o nome do funcionário: " nome_funcionario
    echo "Configure a senha do funcionario $nome_funcionario"
    sudo useradd $nome_funcionario
    echo $nome_funcionario >> $ARQUIVO_FUNCIONARIOS
    sudo passwd $nome_funcionario
    
    numero=1
    echo
    for grupo in ${GRUPOS[@]}; do
      echo -e "\t$numero. $grupo"
      numero=$(($numero + 1))
    done

    read -p "Escolha o grupo: " escolha
    indice=$(($escolha - 1))

    case $escolha in 
      1)
        sudo usermod -aG ${GRUPOS[$indice]} $nome_funcionario
        echo "O funcionário $nome_funcionario foi adicionado com sucesso ao grupo ${GRUPOS[$indice]}"
        ;;
      2)
        sudo usermod -aG ${GRUPOS[$indice]} $nome_funcionario
        echo "O funcionário $nome_funcionario foi adicionado com sucesso ao grupo ${GRUPOS[$indice]}"
        ;;
      3)
        sudo usermod -aG ${GRUPOS[$indice]} $nome_funcionario
        echo "O funcionário $nome_funcionario foi adicionado com sucesso ao grupo ${GRUPOS[$indice]}"
        ;;
      *)
       echo Opção inválida!
       ;;
    esac
  fi
}

function menu(){
  verificarInstacao

  clear
  echo -e "*** \033[32;1mSistema de Gestão de Clinicas :$USER: \033[0m***\n"
  
  echo -e "\t1. Funcionário"
  echo -e "\t2. Paciente"
  echo -e "\t3. Serviço"
  echo -e "\t4. Marcar Consulta"
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
      clear 
      echo -e "** Funcionários :$USER: **\n"

      echo -e "\t1. Cadastrar"
      echo -e "\t2. Listar"
      echo -e "\t3. Remover"
      
      read -p "Escolha: " escolha
      case $escolha in
        1) 
          cadastroFuncionario
        ;;
        2)
          for user in $(cat $ARQUIVO_FUNCIONARIOS); do
            id $user 
          done
          echo
          read -p "preecione ENTER para continuar..."
        ;;
        *)
          echo Opção não disponivel!
          ;;
      esac
      sleep 3
      ;;
    2)
      clear 
      echo -e "** Pacientes :$USER: **\n"

      echo -e "\t1. Cadastrar"
      echo -e "\t2. Listar"
      echo -e "\t3. Remover"
      
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
      ;;
      
     3) # funcionalidade dos serviços
      clear 
      echo -e "** Serviços :$USER: **\n"

      echo -e "\t1. Cadastrar"
      echo -e "\t2. Listar"
      echo -e "\t3. Remover"
      
      read -p "Escolha: " escolha

            case $escolha in
        1) 
          cadastroServico
        ;;
        2)
          for servico in $(cat $ARQUIVO_SERVICOS); do
            echo $servico 
          done
          echo
          read -p "preecione ENTER para continuar..."
        ;;
        *)
          echo Opção não disponivel!
          ;;
      esac
      sleep 3
      ;;
    4) # funcionalidade para marcar consultas
      clear 
      echo -e "** Marcação de Consultas :$USER: **\n"

      echo -e "\t1. Marcar"
      echo -e "\t2. Listar"
      
      read -p "Escolha: " escolha

      case $escolha in
        1) 
          cadastroConsulta
        ;;
        2)
          for servico in $(cat $ARQUIVO_SERVICOS); do
            echo $servico 
          done
          echo
          read -p "preecione ENTER para continuar..."
        ;;
        *)
          echo Opção não disponivel!
          ;;
      esac
      sleep 3
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
