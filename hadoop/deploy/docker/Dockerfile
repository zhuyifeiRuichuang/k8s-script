FROM apache/hadoop-runner
WORKDIR /opt
ARG HADOOP_VERSION=3.1.1
# 提前下载hadoop.tar.gz放在此目录，规避网络波动问题。
COPY hadoop-${HADOOP_VERSION}.tar.gz /opt/hadoop.tar.gz
RUN sudo rm -rf /opt/hadoop \
    && tar zxf hadoop.tar.gz \
    && rm hadoop.tar.gz \
    && mv hadoop* hadoop \
    && rm -rf /opt/hadoop/share/doc
WORKDIR /opt/hadoop
ADD log4j.properties /opt/hadoop/etc/hadoop/log4j.properties
RUN sudo chown -R hadoop:users /opt/hadoop/etc/hadoop/*
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
