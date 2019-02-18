 #!/bin/bash
###########################################
## Script de backup simples do zimbra     #
## Verao v.3 atualizado no dia 08.11.18   #
## Atualizado por Marcello Marafioti      #   
###########################################


# Verificando se o HD de destino esta montado para não apresentar erro
# Se estiver montado vai fazer o if
if mountpoint -q /backup-zimbra
  then
  # Gerando log de controle  
    echo $(date +%d/%m/%Y-%H:%M:%S) - HD JA ESTA MONTADO > /var/log/backup-zimbrav3.txt
    echo $(date +%d/%m/%Y-%H:%M:%S) - INICIANDO O BACKUP >> /var/log/backup-zimbrav3.txt
  # Dir home do Zimbra
  ZHOME=/opt/zimbra
  # Dir de destino do backup
  ZBACKUP=/backup-zimbra
  # Dir de confs do Zimbra
  ZCONFD=$ZHOME/conf
  # Data para versionamento
  DATE=$(date +%d-%m-%Y)
  # Caminho absoluto do backup, com data.
  ZDUMPDIR=$ZBACKUP/$DATE
  # Binário de backup
  ZMBOX=/opt/zimbra/bin/zmmailbox
  # Data para verificação do versionamento.
  # Seguindo a sintaxe, coloque quantos dias de versionamento quer. No meu caso eu deixei com dois
  backupold=$(date --date "3 days ago" +%d-%m-%Y)
  # Arquivo de log
  log=/var/log/backup.log
  # Arquivo de debug, passos mais importantes do script, para debugar mesmo.
  debug=/var/log/backup.debug
  # Conta a enviar e-mail no final do backup
  admin=suporte@aw2net.com.br

  # Nao alterar daqui pra frente.
  # Remove Backups antigos
  echo " Removendo Backups antigos" >> /var/log/backup.debug
  sleep 5
  # Verifica se existem diretórios mais antigos que o setado na variavel backupold
    if [ -d $ZBACKUP/$backupold ] ; then
      rm -rf $ZBACKUP/$backupold
    fi
  # Cria o diretório do dia.
  if [ ! -d $ZDUMPDIR ]; then
  mkdir -p $ZDUMPDIR
  fi

  echo "backup $backupold removido" >> /var/log/backup.debug
  mkdir -p $ZDUMPDIR/ldap-backup/{main_database,config_database,accesslog_db}
  # Gerando lista de contas para o backup.
  echo " Gerando lista ... "
        for mbox in `/opt/zimbra/bin/zmprov -l gaa`
  do
  echo "  Gerando backup da conta $mbox ..."
  echo "Usuário $mbox" >> $debug
  
  #Exportando contas com ZMprov e checando integridade. Caso a saida do comando seja um erro, envia um e-mail para a conta $admin
  echo "inicio backup `date` $mbox " >> $debug
  echo "=================================================" >> $debug
$ZMBOX -z -m $mbox getRestURL "//?fmt=tgz" > $ZDUMPDIR/$mbox.tgz && echo "Backup da conta $mbox OK " || (echo "Subject: FALHA NO BACKUP DO ZIMBRA ";echo "Falhou") | /opt/zimbra/postfix/sbin/sendmail  $admin
  echo "Fim backup `date` $mbox " >> $debug
  echo "=================================================" >> $debug
  done

  echo "iniciando backup da base ldap"
    
  echo $(date +%d/%m/%Y-%H:%M:%S) - DESMONTANDO BACKUP  >> /var/log/backup-zimbrav3.txt
          umount  /backup-zimbra  
   
else
  # Se o HD Não estiver montado vai fazer o else montando o HD     
  # Gerando log de controle  
  echo $(date +%d/%m/%Y-%H:%M:%S) - HD NAO ESTA MONTADO > /var/log/backup-zimbrav3.txt
  echo $(date +%d/%m/%Y-%H:%M:%S) - MONTANDO O HD  >> /var/log/backup-zimbrav3.txt
  echo $(date +%d/%m/%Y-%H:%M:%S) - INICIANDO O BACKUP >> /var/log/backup-zimbrav3.txt
        mount -t nfs 10.1.1.17:/mnt/zimbra-backup /backup-zimbra  
  # Dir home do Zimbra
  ZHOME=/opt/zimbra
  # Dir de destino do backup
  ZBACKUP=/backup-zimbra
  # Dir de confs do Zimbra
  ZCONFD=$ZHOME/conf
  # Data para versionamento
  DATE=$(date +%d-%m-%Y)
  # Caminho absoluto do backup, com data.
  ZDUMPDIR=$ZBACKUP/$DATE
  # Binário de backup
  ZMBOX=/opt/zimbra/bin/zmmailbox
  # Data para verificação do versionamento.
  # Seguindo a sintaxe, coloque quantos dias de versionamento quer. No meu caso eu deixei com dois
  backupold=$(date --date "3 days ago" +%d-%m-%Y)
  # Arquivo de log
  log=/var/log/backup.log
  # Arquivo de debug, passos mais importantes do script, para debugar mesmo.
  debug=/var/log/backup.debug
  # Conta a enviar e-mail no final do backup
  admin=suporte@aw2net.com.br

  # Nao alterar daqui pra frente.
  # Remove Backups antigos
  echo " Removendo Backups antigos" >> /var/log/backup.debug
  sleep 5
  # Verifica se existem diretórios mais antigos que o setado na variavel backupold
    if [ -d $ZBACKUP/$backupold ] ; then
      rm -rf $ZBACKUP/$backupold
    fi
  # Cria o diretório do dia.
  if [ ! -d $ZDUMPDIR ]; then
  mkdir -p $ZDUMPDIR
  fi

  echo "backup $backupold removido" >> /var/log/backup.debug
  mkdir -p $ZDUMPDIR/ldap-backup/{main_database,config_database,accesslog_db}
  # Gerando lista de contas para o backup.
  echo " Gerando lista ... "
        for mbox in `/opt/zimbra/bin/zmprov -l gaa`
  do
  e cho "  Gerando backup da conta $mbox ..."
  echo "Usuário $mbox" >> $debug
  
  #Exportando contas com ZMprov e checando integridade. Caso a saida do comando seja um erro, envia um e-mail para a conta $admin
  echo "inicio backup `date` $mbox " >> $debug
  echo "=================================================" >> $debug
  $ZMBOX -z -m $mbox getRestURL "//?fmt=tgz" > $ZDUMPDIR/$mbox.tgz && echo "Backup da conta $mbox OK " || (echo "Subject: FALHA NO BACKUP DO ZIMBRA ";echo "Falhou") | /opt/zimbra/postfix/sbin/sendmail  $admin
  echo "Fim backup `date` $mbox " >> $debug
  echo "=================================================" >> $debug
  done

  echo "iniciando backup da base ldap"

  echo $(date +%d/%m/%Y-%H:%M:%S) - DESMONTANDO BACKUP  >> /var/log/backup-zimbrav3.txt
        umount  /backup-zimbra  
fi

