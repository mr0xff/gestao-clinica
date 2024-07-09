#!/bin/bash

while true; do
  PONTO_MONTAGEM=/mnt/copia_seguranca
  LOGS_SISTEMA=logs/eventos_sistema.log
  PASTA_BACKUP=copias_seguranca/
  NOME_PARTICAO=/dev/sda3

  if [[ ! -d $PONTO_MONTAGEM ]]; then
    mkdir $PONTO_MONTAGEM
    #chmod -R 777 $PONTO_MONTAGEM
  fi

  TEMPO_BACKUP=$(date +'%Y.%m.%d_%H.%M') # formato da data e hora em: 2024.06.23_11.29
  ARQUIVO_BACKUP="backup_sistema_$TEMPO_BACKUP.zip"

  zip -r9 $PASTA_BACKUP/$ARQUIVO_BACKUP *.lst pacientes_mortos/ logs/ &>/dev/null

  if [[ $? -ne 0 ]]; then
    echo "$TEMPO_BACKUP Falha no backup" >> $LOGS_SISTEMA
    exit -1
  fi
  echo $TEMPO_BACKUP backup feito com sucesso! >> $LOGS_SISTEMA

  mount -t ext4 $NOME_PARTICAO $PONTO_MONTAGEM >> $LOGS_SISTEMA

  if [[ $? -ne 0 ]]; then
    echo $TEMPO_BACKUP Falha na montagem da partição >> $LOGS_SISTEMA
    exit -1
  fi

  #echo $TEMPO_BACKUP Montagem bem sucedida! >> $LOGS_SISTEMA
  cp -r $PASTA_BACKUP/* $PONTO_MONTAGEM/

  if [[ $? -ne 0 ]]; then
    echo $TEMPO_BACKUP Falha na copia dos dados >> $LOGS_SISTEMA
    exit -1
  fi

  umount $PONTO_MONTAGEM

  if [[ $? -ne 0 ]]; then
    echo $TEMPO_BACKUP Falha na desmontagem da partição! >> $LOGS_SISTEMA
    exit -1
  fi

  echo $TEMPO_BACKUP Processo concluído! >> $LOGS_SISTEMA
  sleep 60
done