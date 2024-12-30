FROM ubuntu:24.02
WORKDIR /app
COPY fx.tar.xz .
RUN tar xf fx.tar.xz
RUN chmod +x run.sh
CMD ./run.sh