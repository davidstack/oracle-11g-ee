#!/bin/bash

mount -t tmpfs shmfs -o size=4g /dev/shm

#replace hostname when start container every time
echo "replace listener.ora and tnsnames.ora"
cp /opt/listener.ora $ORACLE_HOME/network/admin/listener.ora
cp /opt/tnsnames.ora $ORACLE_HOME/network/admin/tnsnames.ora
sed -i "s#oradb11g#$HOSTNAME#" $ORACLE_HOME/network/admin/listener.ora
sed -i "s#oradb11g#$HOSTNAME#" $ORACLE_HOME/network/admin/tnsnames.ora

#health check
while true; do
  status=`ps -ef | grep tns | grep oracle | grep -v grep`
  pmon=`ps -ef | egrep pmon_$ORACLE_SID'\>' | grep -v grep`
  if [ "$status" == "" ] || [ "$pmon" == "" ]
  then
    echo "starting database"
    su - oracle -c "lsnrctl start"
    su - oracle -c "sqlplus /nolog @?/config/scripts/startdb.sql"
    su - oracle -c "lsnrctl status"
  else
    echo "start database success"
    break
  fi
  sleep 1m
done

#need rebuild so in container ,we do not start db console
#while true; do
#  dbconsole=`ps -ef | grep "emwd.pl dbconsole" | grep -v grep`
#  if [ "$dbconsole" == "" ]
#  then
#    echo "starting dbconsole"
#    su - oracle -c "emctl start dbconsole"
#  else
#    echo "start dbconsole success"
#    break
#  fi 
#  sleep 1m
#done;
	
INIT_FILE="/opt/initfinished"
if [ -f "$INIT_FILE" ]; then 
    echo "database has init finished,start database only..."
else
	echo "Database not initialized. Initializing database."
	if [ -z "$CHARACTER_SET" ]; then
		export CHARACTER_SET="ZHS16GBK"
	fi
	export IMPORT_FROM_VOLUME=true
fi



if [ $IMPORT_FROM_VOLUME ]; then
	echo "Starting import from '/docker-entrypoint-initdb.d':"
    #create table
	for f in /docker-entrypoint-initdb.d/table/*; do
		echo "found file /docker-entrypoint-initdb.d/table/$f"
		case "$f" in
			*.sql)    echo "[IMPORT] $0: running $f"; echo "exit" | su oracle -c "NLS_LANG=.$CHARACTER_SET $ORACLE_HOME/bin/sqlplus -S / as sysdba @$f"; echo ;;
			*)        echo "[IMPORT] $0: ignoring $f" ;;
		esac
		echo
	done
	
	#import data
	for f in /docker-entrypoint-initdb.d/data/*; do
		echo "found file /docker-entrypoint-initdb.d/data/$f"
		case "$f" in
			*.sql)    echo "[IMPORT] $0: running $f"; echo "exit" | su oracle -c "NLS_LANG=.$CHARACTER_SET $ORACLE_HOME/bin/sqlplus -S / as sysdba @$f"; echo ;;
		    *.dmp)    echo "[IMPORT] $0: running $f"; impdp $f ;;
			*)        echo "[IMPORT] $0: ignoring $f" ;;
		esac
		echo
	done
    touch $INIT_FILE
	echo "Import finished"
	echo
else
	echo "[IMPORT] Not a first start, SKIPPING Import from Volume '/docker-entrypoint-initdb.d'"
	echo "[IMPORT] If you want to enable import at any state - add 'IMPORT_FROM_VOLUME=true' variable"
	echo
fi

#health cheack
while true; do
  status=`ps -ef | grep tns | grep oracle | grep -v grep`
  pmon=`ps -ef | egrep pmon_$ORACLE_SID'\>' | grep -v grep`
  if [ "$status" == "" ] || [ "$pmon" == "" ]
  then
    echo "database status unnormal"
  else
    echo "database status normal"
  fi
  sleep 2m
done



