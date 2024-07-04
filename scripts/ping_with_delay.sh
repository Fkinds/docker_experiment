#!/bin/sh

# コンテナ名
CONTAINER_NAME=$1
# 遅延時間（ミリ秒）
DELAY=$2

# 宛先コンテナのIPアドレスを取得
DEST_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)

if [ -z "$DEST_IP" ]; then
  echo "コンテナ $CONTAINER_NAME のIPアドレスを取得できませんでした。"
  exit 1
fi

echo "コンテナ $CONTAINER_NAME のIPアドレスは $DEST_IP です。"

# 既存の設定を削除
tc qdisc del dev eth0 root 2>/dev/null

# eth0インターフェースに遅延を追加
tc qdisc add dev eth0 root netem delay ${DELAY}ms

# 遅延付きでpingを実行
ping $DEST_IP
