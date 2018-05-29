FROM oraclelinux:latest
MAINTAINER DamonWang <wangdk789@163.com>

RUN echo 23.46.220.130 yum.oracle.com >>/etc/hosts && yum upgrade -y
RUN echo 23.46.220.130 yum.oracle.com >>/etc/hosts && yum install -y oracle-rdbms-server-11gR2-preinstall unzip sysstat smartmontools net-tools && yum clean all && rm -rf /var/cache/yum
RUN mkdir /opt/oracle /opt/oraInventory /opt/datafile \
 && chown oracle:oinstall -R /opt

ADD install/linux.x64_11gR2_database_1of2.zip /tmp/install/linux.x64_11gR2_database_2of2.zip
ADD install/linux.x64_11gR2_database_2of2.zip /tmp/install/linux.x64_11gR2_database_1of2.zip
RUN cd /tmp/install && unzip linux.x64_11gR2_database_1of2.zip && unzip linux.x64_11gR2_database_2of2.zip && rm *.zip

ENV ORACLE_BASE /opt/oracle
ENV ORACLE_HOME $ORACLE_BASE/product/11.2.0/dbhome_1

ADD install/oraInst.loc /etc/oraInst.loc
RUN chmod 644 /etc/oraInst.loc

ADD install/db_install.rsp /tmp/install/db_install.rsp
ADD install/install /tmp/install/install
RUN chmod 750 /tmp/install/install