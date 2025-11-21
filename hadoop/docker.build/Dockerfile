# 若自定义基础镜像，请替换
FROM apache/hadoop-runner
WORKDIR /opt
# 在此处指定hadoop版本
ARG HADOOP_VERSION=3.1.1
# 复制本地hadoop tar.gz到容器内，必须手动提前下载
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
RUN mkdir -p /opt/hadoop/data
RUN chown -R hadoop:hadoop /opt/hadoop/data
