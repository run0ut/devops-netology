FROM centos:7
RUN yum -y install --setopt=tsflags=nodoc wget perl-Digest-SHA && \
    yum clean all
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.0-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.0-linux-x86_64.tar.gz.sha512 && \
    shasum -a 512 -c elasticsearch-7.16.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.16.0-linux-x86_64.tar.gz
RUN wget perl-Digest-SHA && \
    yum -y autoremove
RUN cd elasticsearch-7.16.0/ 
EXPOSE 9200
EXPOSE 9300
CMD ["sh", "-c", "./bin/elasticsearch"]