# ベースイメージとしてubuntu:20.04を使用
FROM ubuntu:20.04

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y iputils-ping iproute2 curl gnupg lsb-release software-properties-common

# Docker CLIをインストール
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# シェルスクリプトをコピー
COPY scripts /scripts

# コンテナが起動したら無限に待機
CMD ["sh", "-c", "sleep infinity"]
