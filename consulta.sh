#!/bin/bash
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

  servicoNome=$(nl $ARQUIVO_SERVICOS | grep $servico | awk -F' ' '{print $2}' | awk -F: '{print $1}')
  echo "$medico:$paciente:$servicoNome:$hora:$prioridade:pendente" >> $ARQUIVO_CONSULTAS_MARCADAS
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

  echo "Lista das consultas marcadas para si, $USER"
  numeroPaciente=1

  for consulta in $(cat $ARQUIVO_CONSULTAS_MARCADAS); do
    marcados=$(echo $consulta | grep $USER)
    if [[ -n $marcados ]]; then 
      echo $consulta | tr : '\t' | sort -k6 | awk -F' ' '{print $2}'
      #echo -e "\t$numeroPaciente. $marcados"
      numeroPaciente=$(($numeroPaciente+1))
    fi
  done

  read -p "Escolha o paciente: " pacienteEscolhido
  read -p "Informe o seu estado: " estado
  read -p "Informe a doença: " doenca
  
  if [[ $estado='morto' || $estado='morta' ]]; then 
      read -p "Motivo da morte: " motivo
      echo $USER:$pacienteEscolhido:$estado:$doenca:$motivo > $PASTA/$pacienteEscolhido.log
  else
    read -p "Infome os medicamentos a serem tomados: " medicamentos

    echo -e "\t1. Cash"
    echo -e "\t2. Multicaixa *" 

    pagamentoEscolhdo="multicaixa"

    read -p "Escolha a forma de pagamento: " pagamento 

    if [[ $pagamento -eq 1 ]]; then
      pagamentoEscolhdo=cash
    else
      pagamentoEscolhdo=multicaixa
    fi
  
    echo "$USER:$pacienteEscolhido:$estado:$doenca:$medicamentos:$pagamentoEscolhdo" >> $ARQUIVO_CONSULTAS_ATENDIDAS 
  fi 

  echo "Actualize o estado do paciente!"
  sleep 2
  nano $ARQUIVO_CONSULTAS_MARCADAS
  read -p "Precione Enter para continuar ..." 
}

clear 
echo -e "** Marcação de Consultas :$USER: **\n"

echo -e "\t1. Marcar"
echo -e "\t2. Ver todas as consultas"
echo -e "\t3. Antender consultas marcadas para $USER"

read -p "Escolha: " escolha

case $escolha in
  1) 
    cadastroConsulta
  ;;
  2)
    for consulta in $(cat $ARQUIVO_CONSULTAS_MARCADAS); do
      echo $consulta | tr : '\t' | sort -k6
    done
    echo
    read -p "preecione ENTER para continuar..."
  ;;
  3)
    atenderConsulta
  ;;
  *)
    echo Opção não disponivel!
    ;;
esac
sleep 3