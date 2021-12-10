FROM centos:7

USER 0

EXPOSE 9200
EXPOSE 9300

RUN useradd -m -u 1000 elasticsearch

RUN yum -y install wget 
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.0-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.0-linux-x86_64.tar.gz.sha512 && \
    sha512sum -c elasticsearch-7.16.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.16.0-linux-x86_64.tar.gz && \
    rm -f elasticsearch-7.16.0-linux-x86_64.tar.gz* && \
    mv elasticsearch-7.16.0 /elasticsearch
RUN chown elasticsearch:elasticsearch -R /elasticsearch
RUN yum -y remove wget && \
    yum -y autoremove && \
    yum clean all

USER 1000

ENV ES_JAVA_OPTS="-Xms256m -Xmx512m" \
    ES_HOME="/elasticsearch"

WORKDIR ${ES_HOME}

CMD ["sh", "-c", "${ES_HOME}/bin/elasticsearch"]