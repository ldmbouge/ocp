FROM williamyeh/ansible:ubuntu16.04
SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get install -y --force-yes \
supervisor \
sudo unzip cmake libxml2-dev libgnutls-dev

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
echo keyboard-configuration keyboard-configuration/layout select 'English (US)' | debconf-set-selections && \
echo keyboard-configuration keyboard-configuration/layoutcode select 'fr' | debconf-set-selections && \
apt-get update && apt-get install -y --force-yes xorg

RUN apt-get update && apt-get install -y --force-yes \
libfreetype6-dev libcairo2-dev libxt-dev libjpeg-dev libtiff5-dev \
openssh-server

RUN apt-get install -y --force-yes \
emacs24-nox \
clang-4.0 git \
autoconf automake \
libdispatch-dev    

RUN useradd -m -u 1000 -p `openssl passwd -crypt appsec` appdev && \
chsh -s /bin/bash appdev && \
addgroup appdev sudo

#conf supervisor uncomment if you want to use supervisor
#RUN mkdir -p /var/log/supervisor
#COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

USER appdev
WORKDIR /home/appdev

USER root
Add install-gnustep.sh ./install-gnustep.sh
RUN chmod +x install-gnustep.sh
RUN ./install-gnustep.sh

USER appdev

EXPOSE 22

#uncomment if you want to use supervisor
#ENTRYPOINT ["/usr/bin/supervisord"]

ENTRYPOINT ["/bin/bash"]