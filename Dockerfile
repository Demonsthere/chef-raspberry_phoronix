FROM armv7/armhf-debian

ONBUILD RUN sudo apt-get -qq update

MAINTAINER jakub.blaszczyk@sap.com

ENV DEBIAN_FRONTEND noninteractive

ADD files/default/qemu-arm-static /usr/bin/

RUN apt-get -qq update
RUN apt-get -qq install -o=Dpkg::Use-Pty=0 -y --no-install-recommends chef > /dev/null
RUN apt-get -qq install -o=Dpkg::Use-Pty=0 -y --no-install-recommends sudo > /dev/null

RUN useradd -ms /bin/bash vagrant 

RUN usermod -aG sudo vagrant

RUN echo "vagrant ALL=NOPASSWD:ALL" >> /etc/sudoers.d/vagrant

USER vagrant

RUN sudo mkdir -p /opt/chef/embedded/bin
RUN sudo ln -s /usr/bin/gem /opt/chef/embedded/bin/gem
RUN sudo ln -s /usr/bin/ruby /opt/chef/embedded/bin/ruby

