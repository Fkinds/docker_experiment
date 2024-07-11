# ベースイメージとしてubuntu:20.04を使用
FROM ubuntu:20.04

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    quagga \
    isc-dhcp-server \
    iproute2 \
    iputils-ping \
    isc-dhcp-client \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*


# Docker CLIをインストール
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# Quagga設定ファイルのコピー
COPY quagga/router1/zebra.conf /etc/quagga/zebra.conf
COPY quagga/router1/ospfd.conf /etc/quagga/ospfd.conf
COPY quagga/router2/zebra.conf /etc/quagga/zebra.conf
COPY quagga/router2/ospfd.conf /etc/quagga/ospfd.conf

# DHCPサーバー設定ファイルのコピー
COPY dhcpd.conf /etc/dhcp/dhcpd.conf

# 起動スクリプトのコピー
# 起動スクリプトのコピー
COPY scripts/start.sh /start.sh
COPY scripts/ping_with_delay.sh /ping_with_delay.sh
RUN chmod +x /start.sh /ping_with_delay.sh


# QuaggaとDHCPサーバーを起動
CMD ["/start.sh","/ping_with_delay.sh"]
