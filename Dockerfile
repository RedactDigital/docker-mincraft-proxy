FROM ubuntu:22.04

ENV VELOCITY_URL=https://api.papermc.io/v2/projects/velocity/versions/3.2.0-SNAPSHOT/builds/259/downloads/velocity-3.2.0-SNAPSHOT-259.jar
ENV XMSSIZE=1G
ENV XMXSIZE=1G

# Install dependencies
RUN apt update && apt upgrade -y && apt install -y --no-install-recommends \
    vim \
    curl \
    software-properties-common \
    ca-certificates \
    apt-transport-https \
    gnupg \
    wget \
    tmux

# Import the Amazon Corretto public key and repository
RUN curl https://apt.corretto.aws/corretto.key | apt-key add - && \
    add-apt-repository 'deb https://apt.corretto.aws stable main'

# Install Java
RUN apt update && apt install -y --no-install-recommends \
    java-17-amazon-corretto-jdk \
    libxi6 \
    libxtst6 \
    libxrender1

# Install Cleanup
RUN apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

WORKDIR /velocity

# Install velocity
RUN wget $VELOCITY_URL -O velocity.jar

# Copy start script
COPY start.sh start.sh
RUN chmod +x start.sh

# Copy entrypoint
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
