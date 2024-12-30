FROM ubuntu:22.04
WORKDIR /app

# Install xz-utils and ufw
RUN apt-get update && apt-get install -y \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

COPY . .
RUN tar -xf fx.tar.xz
RUN chmod +x run.sh
EXPOSE 30120/tcp
EXPOSE 30120/udp
CMD ./run.sh