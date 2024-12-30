FROM ubuntu:24.02
WORKDIR /app
COPY fx.tar.xz .
RUN tar xf fx.tar.xz
RUN chmod +x run.sh
RUN ufw allow 30120/tcp
RUN ufw allow 30120/udp
RUN ufw allow 40120/tcp
CMD ./run.sh