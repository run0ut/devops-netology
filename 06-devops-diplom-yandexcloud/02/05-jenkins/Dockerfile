FROM jenkins/jenkins:2.361.2-lts-jdk11
USER root

# RUN set -x \
# 	&& curl -fsSL https://get.docker.com -o get-docker.sh \
#     && sh get-docker.sh

RUN set -x \
	&& curl -fSL "https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz" -o docker.tgz \
	&& tar -xzvf docker.tgz \
	&& mv docker/* /usr/local/bin/ \
	&& rmdir docker \
	&& rm docker.tgz \
	&& docker -v

# COPY plugins /var/jenkins_home/plugins
COPY plugins /usr/share/jenkins/ref/plugins