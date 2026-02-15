FROM debian:13.3-slim

RUN useradd -m james


RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa wget

USER james

ENV HOME=/home/james

ENV PATH="/home/james/.local/bin:/home/james/flutter/bin:${PATH}"

RUN curl -fsSL https://claude.ai/install.sh | bash
RUN curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

WORKDIR /home/james

RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.41.1-stable.tar.xz
RUN tar -xf flutter_linux_3.41.1-stable.tar.xz -C /home/james/

RUN wget https://dl.google.com/android/repository/commandlinetools-linux-x86_64.zip


WORKDIR /workspace
