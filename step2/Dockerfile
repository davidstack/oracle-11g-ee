FROM oracle-11g:installed
MAINTAINER DamonWang

ADD dbca.rsp /tmp/install/dbca.rsp
ADD conf_finish.sql $ORACLE_HOME/config/scripts/conf_finish.sql

ADD create /tmp/install/create
RUN chmod 750 /tmp/install/create

