#!/bin/bash
# 1. Fazer o backup dos dados
# 2. Montar a partição do backup 
# 3. Mover para para la
# 4. Desmontar a partição

PONTO_MONTAGEM=/mnt/copia_seguranca
LOGS_SISTEMA=logs/eventos_sistema.log

if [[ ! -d $PONTO_MONTAGEM ]]; then
  mkdir $PONTO_MONTAGEM
  #chmod -R 777 $PONTO_MONTAGEM
fi

clear 
echo -e "** Fazendo o backup dos dados do sistema :$USER: **\n"

TEMPO_BACKUP=$(date +'%Y.%m.%d_%H.%M') # formato da data e hora em: 2024.06.23_11.29
ARQUIVO_BACKUP="backup_sistema_$TEMPO_BACKUP.zip"

echo "iniciando o backup dos dados ..."
zip -r9 $PASTA_BACKUP/$ARQUIVO_BACKUP *.lst pacientes_mortos/ logs/ &>/dev/null

if [[ $? -ne 0 ]]; then
  echo "$TEMPO_BACKUP Falha no backup" >> $LOGS_SISTEMA
  echo
  read -p "Pressione Enter para continuar ... "
  exit -1
fi
echo $TEMPO_BACKUP backup feito com sucesso! >> $LOGS_SISTEMA
echo "Mountando a partição ..."
mount $NOME_PARTICAO $PONTO_MONTAGEM 2>>$LOGS_SISTEMA

if [[ $? -ne 0 ]]; then
  echo $TEMPO_BACKUP Falha na montagem da partição >> $LOGS_SISTEMA
  echo
  read -p "Pressione Enter para continuar ... "
  exit -1
fi

echo $TEMPO_BACKUP Montagem bem sucedida! >> $LOGS_SISTEMA
cp -r $PASTA_BACKUP/* $PONTO_MONTAGEM/

if [[ $? -ne 0 ]]; then
  echo $TEMPO_BACKUP Falha na copia dos dados >> $LOGS_SISTEMA
  echo
  read -p "Pressione Enter para continuar ... "
  exit -1
fi

umount $PONTO_MONTAGEM

if [[ $? -ne 0 ]]; then
  echo $TEMPO_BACKUP Falha na desmontagem da partição! >> $LOGS_SISTEMA
  echo
  read -p "Pressione Enter para continuar ... "
  exit -1
fi

echo $TEMPO_BACKUP Processo concluído! >> $LOGS_SISTEMA
echo Processo concluído!
echo
read -p "Pressione Enter para continuar ... "