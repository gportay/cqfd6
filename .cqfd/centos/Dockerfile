FROM centos

ENV LANG en_US.utf8
ENV LC_ALL en_US.utf8
ENV HOME /home/builder
ENV SSH_AUTH_SOCK /home/builder/.sockets/ssh

# cqfd mandatory packages
RUN yum -y update && yum -y install \
	make \
	asciidoctor

WORKDIR /home/builder/src
VOLUME /home/builder/src
