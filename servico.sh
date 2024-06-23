#!/bin/bash

function cadastroServico(){
	clear
  echo -e "** Cadastro de Serviços :$USER: **\n"

  read -p "Nome do serviço: " servico
  read -p "Preço do serviço: " preco

  echo "$servico":$preco >> $ARQUIVO_SERVICOS
  echo -e "Serviço $servico foi cadastrado com sucesso!"
	
}

clear 
echo -e "** Serviços :$USER: **\n"

echo -e "\t1. Cadastrar"
echo -e "\t2. Listar"

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