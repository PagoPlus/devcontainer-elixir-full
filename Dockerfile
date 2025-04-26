FROM mcr.microsoft.com/devcontainers/typescript-node:22-bookworm
      
# Install docker client
ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 28.1.1
RUN curl -fsSL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" \
  | tar -xzC /usr/local/bin --strip=1 docker/docker

# Install docker compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# Install dependencies for asdf and Erlang/Elixir, and also Go for asdf
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    git \
    curl \
    build-essential \
    autoconf \
    libssl-dev \
    libncurses5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    unzip \
    gcc \
    sudo \
    golang \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Create codespace user
USER node
ENV HOME /home/node

# Set up Go
ENV GOPATH $HOME/go
ENV PATH $GOPATH/bin:$PATH

# Set ASDF_DIR environment variable
ENV ASDF_DATA_DIR=$HOME/.asdf
ENV PATH=$ASDF_DATA_DIR/shims:$PATH
RUN echo 'export PATH="$ASDF_DATA_DIR:$ASDF_DATA_DIR/shims:$PATH"' >> $HOME/.bashrc
ENV PATH $ASDF_DATA_DIR:$PATH

# Install asdf
ARG ASDF_VERSION=0.16.7
RUN mkdir -p ${ASDF_DATA_DIR} && \
  curl -sL https://github.com/asdf-vm/asdf/releases/download/v${ASDF_VERSION}/asdf-v${ASDF_VERSION}-linux-amd64.tar.gz | \
  tar -xzC ${ASDF_DATA_DIR}
RUN chmod +x $ASDF_DATA_DIR/asdf

# Install Erlang and Elixir via asdf
RUN asdf plugin add erlang
RUN asdf plugin add elixir
RUN asdf install erlang 27.2
RUN asdf install elixir 1.18.0-otp-27
# RUN asdf set erlang 27.2
# RUN asdf set elixir 1.18.0-otp-27