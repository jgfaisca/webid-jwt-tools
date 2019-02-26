# version 1.0 

FROM ubuntu:latest

MAINTAINER Jose G. Faisca <jose.faisca@gmail.com>

# -- Terminal variable --
ENV TERM xterm

# -- Install dependencies --
RUN apt-get update && apt-get install -y netcat curl 

# -- Clean --
RUN cd / \
        && apt-get autoremove -y \
        && apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#  -- Ports for HTTP --
EXPOSE 8888/tcp

COPY consume-jwt.sh /usr/local/bin
COPY response.sh /usr/local/bin

CMD ["consume-jwt.sh"]
