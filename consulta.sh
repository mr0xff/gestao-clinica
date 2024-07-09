#!/bin/bash
function marcarConsulta(){
	clear
  echo -e "** Marcação de Consultas :$USER: **\n"
	
	grep medicos /etc/group | cut -d: -f4 | tr , \\n
  echo 

  read -p "Informe o Nome do Medico: " medico
  echo
 	
  for paciente in `cat $ARQUIVO_PACIENTES`;
  do
  	echo $paciente | grep -v atendido | cut -d: -f1
  done
  echo 
  read -p "Informe o nome do paciente: " paciente
  echo
  
  indice=1
  for servico in `cat $ARQUIVO_SERVICOS`;
  do
  	echo $indice. $servico
  	indice=$(($indice+1))
  done
  
  read -p "Escolha o serviço: " servico
  read -p "Informe a Hora da consulta: " hora
  read -p "Informe a prioridade da consulta: " prioridade

  servicoNome=$(nl $ARQUIVO_SERVICOS | grep $servico | awk -F' ' '{print $2}' | awk -F: '{print $1}')
  echo "$medico:$paciente:$servicoNome:$hora:$prioridade:por_atender" >> $ARQUIVO_CONSULTAS_MARCADAS
  echo -e "Consulta marcada com sucesso!"
}

function atenderConsulta(){
  clear
  echo -e "** Atender Consultas Marcadas:$USER: **\n"
  id $USER | grep medicos > /dev/null

  if [[ $? -ne 0 ]]; then
    echo "Desculpe, somente médicos podem aceder a esta funcionalidade!"
    read -p "Precione Enter para continuar ..."  
    exit -1 
  fi
  echo -e "[$(date +%D)] $USER entrou antender consulta">>logs/eventos_sistema.log
  echo -e "Lista das consultas marcadas para si, $USER:\n"
  numeroPaciente=1

  for consulta in $(cat $ARQUIVO_CONSULTAS_MARCADAS); do
    marcados=$(echo $consulta | grep $USER) # para mostrar apenas as consultas marcadas para o medico logado
    if [[ -n $marcados ]]; then 
      echo $consulta | tr : '\t' | sort -k6 | awk -F' ' '{print $2}'
      numeroPaciente=$(($numeroPaciente+1))
    fi
  done

  read -p "Escolha o paciente: " pacienteEscolhido
  read -p "Informe a doença: " doenca

    echo -e "\t1. Cash"
    echo -e "\t2. Multicaixa *" 

    pagamentoEscolhdo="multicaixa"

    read -p "Escolha a forma de pagamento: " pagamento 

    if [[ $pagamento -eq 1 ]]; then
      pagamentoEscolhdo=cash
    else
      pagamentoEscolhdo=multicaixa
    fi
  
    echo "$USER:$pacienteEscolhido:$doenca:$pagamentoEscolhdo" >> $ARQUIVO_CONSULTAS_ATENDIDAS 

  echo -e "A consulta do paciente $pacipacienteEscolhido foi realizada com sucesso!"
  read -p "Precione Enter para continuar ..." 
}

function marcarComoMorto(){
  groups | grep medicos > /dev/null # verifica se o usuario é administrador

  if [[ $? -ne 0 ]]; then 
    echo Apenas medicos do sistema
    sleep 3
  else
    echo "[$(date +%D)] $USER entrou em marcar morto">>logs/eventos_sistema.log
    echo "MEDICO:PACIENTE:DOENÇA:METODO_DE_PAGAMENTO" | tr : '\t'
    for consulta in $(cat $ARQUIVO_CONSULTAS_ATENDIDAS); do
      echo $consulta | tr : '\t' | sort -k6 -d 
    done
    echo
    read -p "Informe o nome do paciente:" paciente
    read -p "Informe a causa da morte: " causa
    read -p "Informe o data da morte [dia-mes-ano]: " data
    
    echo -e "Nome: $paciente\nCausa da Morte: $causa\nData: $data" > $PASTA/$paciente.txt
    fgrep -v -e ":$paciente:"  consultas_marcadas.lst | tee consultas_marcadas.lst # remover o paciente dado como morto da lista dos marcados
    read -p "Registrado como morto com sucesso!"
  fi
}

clear 
echo -e "** Marcação de Consultas :$USER: **\n"

echo -e "\t1. Marcar"
echo -e "\t2. Ver consultas marcadas"
echo -e "\t3. Antender consultas marcadas"
echo -e "\t4. Marcar paciente como morto"
echo -e "\t5. Ver consultas antendidas"
echo -e "\t0. Sair"

read -p "Escolha: " escolha

case $escolha in
  1) 
    marcarConsulta
  ;;
  2)
    echo "[$(date +%D)] $USER entrou em listar consultas marcadas">>logs/eventos_sistema.log
  	echo "MEDICO:PACIENTE:SERVIÇO:HORA:PRIORIDADE:ESTADO" | tr : '\t'
    for consulta in $(cat $ARQUIVO_CONSULTAS_MARCADAS); do
      echo $consulta | tr : '\t' | sort -k6 -d 
    done
    echo
    read -p "Actualizar estdo de um paciente?[s/n]: " resposta
  
    case $resposta in 
      s)
        echo -e "\t1. VI"
        echo -e "\t2. Nano"

        read -p "Escolha o editor de texto: " editor 
        case $editor in 
          1)
            vi $ARQUIVO_CONSULTAS_MARCADAS
          ;;
          *)
            nano $ARQUIVO_CONSULTAS_MARCADAS
          ;;
        esac
      ;;
    esac
  ;;
  3)
    atenderConsulta
  ;;
  4)
    marcarComoMorto
  ;;
  5)
    groups | grep medicos > /dev/null # verifica se o usuario é administrador

    if [[ $? -ne 0 ]]; then 
      echo Apenas medicos do sistema
      sleep 3
    else
      echo "[$(date +%D)] $USER entrou em listar consultas antendidas" >> logs/eventos_sistema.log
      echo "MEDICO:PACIENTE:DOENÇA:METODO_DE_PAGAMENTO" | tr : '\t'
      for consulta in $(cat $ARQUIVO_CONSULTAS_ATENDIDAS); do
        echo $consulta | tr : '\t' | sort -k6 -d 
      done
      echo
      read -p "preecione ENTER para continuar..."
    fi
  ;;
  0)
    exit 
    ;;
  *)
    echo Opção não disponivel!
    ;;
esac
sleep 3
