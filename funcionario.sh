#!/bin/bash
export GRUPOS=(enfermeiros medicos administradores)

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

clear 
echo -e "** Funcionários :$USER: **\n"

echo -e "\t1. Cadastrar"
echo -e "\t2. Listar"

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