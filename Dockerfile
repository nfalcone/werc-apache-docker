FROM ubuntu:latest

MAINTAINER Nick Falcone <nick@nfalcone.info>

#Prep work
RUN apt-get update
RUN apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get install build-essential apache2 mercurial libx11-dev libxtst-dev libxt-dev libtext-markdown-perl imagemagick -y

#Build plan9port
COPY plan9port-20140306.tgz /root/
RUN cd /root && tar zxf /root/plan9port-20140306.tgz
RUN mv /root/plan9port /usr/local/plan9
RUN cd /usr/local/plan9 && ./INSTALL

#Bring in werc
RUN hg clone https://bitbucket.org/nfalcone/werc /var/werc
RUN export HOSTNAME=docker.nfalcone.info && cd /var/werc/sites && mv werc.cat-v.org $HOSTNAME

#Apache time
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
EXPOSE 80
COPY werc-apache.conf /etc/apache2/sites-enabled/000-default.conf
RUN a2enmod rewrite
RUN a2enmod cgi

#Start her up
CMD /usr/sbin/apache2ctl -D FOREGROUND

