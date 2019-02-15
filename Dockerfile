FROM ldmbis/gnustep:3.6
RUN adduser --disabled-password --gecos '' ldm -u 1000 && adduser ldm sudo
USER ldm
WORKDIR /home/ldm
