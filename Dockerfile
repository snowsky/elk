# -*- mode:dockerfile -*-
FROM ubuntu:14.04

RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf && \
        echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf

RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apt-transport-https \
        ca-certificates-java \
        curl \
        software-properties-common && \
        rm -rf /var/cache/apt/archives

RUN mkdir -p /opt/elasticsearch && curl https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.5.0.tar.gz | tar zxv -C /opt/elasticsearch --strip-components 1
RUN mkdir -p /opt/logstash && curl https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz | tar zxv -C /opt/logstash --strip-components 1
RUN mkdir -p /opt/kibana && curl https://download.elasticsearch.org/kibana/kibana/kibana-4.0.1-linux-x64.tar.gz | tar zxv -C /opt/kibana --strip-components 1

## Install some bootstrap utilities ##
RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apt-transport-https \
        ca-certificates-java \
        curl \
        software-properties-common && \
        rm -rf /var/cache/apt/archives


RUN add-apt-repository ppa:webupd8team/java -y && \
        echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | \
        /usr/bin/debconf-set-selections

# git
RUN add-apt-repository ppa:git-core/ppa -y

# node
RUN add-apt-repository ppa:chris-lea/node.js -y


# docker
RUN add-apt-repository 'deb https://get.docker.io/ubuntu docker main' -y && \
        curl -LSs 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xD8576A8BA88D21E9' | \
        apt-key adv --import -


# trusty repos
RUN add-apt-repository 'deb http://us.archive.ubuntu.com/ubuntu/ trusty main'
RUN add-apt-repository 'deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates main'
RUN add-apt-repository 'deb http://us.archive.ubuntu.com/ubuntu/ trusty-backports main'
RUN add-apt-repository 'deb http://security.ubuntu.com/ubuntu trusty-security main'

RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apparmor \
        apache2 \
        aufs-tools \
        autoconf \
        automake \
        bash \
        bison \
        build-essential \
	djbdns \
	lxc-docker \
	runit \
	ssh && \
	rm -rf /var/cache/apt/archives

RUN echo 'root:elkelk' | chpasswd

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN useradd -m -s /bin/bash elk && adduser elk docker 

#don't need this in new version
#RUN sed -i 's/"+window.location.hostname+"/localhost/' /opt/kibana/config.js

# APACHE2 Configuration
# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid 

#RUN ln -s $(readlink -f /opt/kibana) /var/www/html/kibana

RUN mkdir /root/.ssh/
ADD id_rsa* /root/.ssh/

ADD etc.tar /
ADD home.tar /
ADD data/* /tmp/
RUN chown -R elk.elk /home/elk/.ssh

CMD ["/sbin/runit"]

EXPOSE 22 80 5601 9200 9300
