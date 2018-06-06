FROM oracle-11g:created
MAINTAINER DamonWang <wangdk789@163.com>

ENV ORACLE_SID=pubinfo

RUN rm -rf /tmp/install
RUN rm -rf /tmp/create

# Exposes the default TNS port, as well as the Enterprise Manager HTTPS (1158) port.
EXPOSE 1521 1158 8080

ADD startdb.sql $ORACLE_HOME/config/scripts/startdb.sql
ADD listener.ora /tmp/listener.ora 
ADD tnsnames.ora /tmp/tnsnames.ora 
ADD entry-point.sh /usr/local/bin/entry-point.sh
RUN chmod 750 /usr/local/bin/entry-point.sh
CMD /usr/local/bin/entry-point.sh
