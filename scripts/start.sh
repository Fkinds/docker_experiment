#!/bin/bash

# DHCPサーバーの設定
service isc-dhcp-server start

# Quaggaのディレクトリを作成
mkdir -p /run/quagga
chown quagga:quagga /run/quagga

mkdir -p /var/run/quagga
chown quagga:quagga /var/run/quagga

# Quaggaのログディレクトリを作成
mkdir -p /var/log/quagga
chown quagga:quagga /var/log/quagga

# 既存のPIDファイルを削除
rm -f /run/quagga/zebra.pid
rm -f /run/quagga/ospfd.pid

# Quaggaのデーモンを起動
zebra -d -f /etc/quagga/zebra.conf
ospfd -d -f /etc/quagga/ospfd.conf

# 無限ループで待機
tail -f /dev/null

