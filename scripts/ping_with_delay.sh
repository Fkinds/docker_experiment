#!/bin/bash

# ソースコンテナ名と宛先コンテナ名および遅延時間を引数として受け取る
SOURCE_CONTAINER=$1
DEST_CONTAINER=$2
DELAY=$3

# 宛先コンテナのIPアドレスを取得
DEST_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' $DEST_CONTAINER | awk '{print $1}')

if [ -z "$DEST_IP" ]; then
  echo "コンテナ $DEST_CONTAINER のIPアドレスを取得できませんでした。"
  exit 1
fi

echo "コンテナ $DEST_CONTAINER のIPアドレスは $DEST_IP です。"

# ソースコンテナのPIDを取得
SOURCE_PID=$(docker inspect -f '{{.State.Pid}}' $SOURCE_CONTAINER)

# ネームスペースディレクトリを作成
sudo mkdir -p /var/run/netns
sudo ln -sf /proc/$SOURCE_PID/ns/net /var/run/netns/$SOURCE_CONTAINER

# ソースコンテナのインターフェース名を取得
IFACES=$(sudo ip netns exec $SOURCE_CONTAINER ip -o link show | awk -F': ' '{print $2}')

# 各インターフェースに遅延を追加
for IFACE in $IFACES; do
  # 既存のtc qdisc設定を削除
  sudo ip netns exec $SOURCE_CONTAINER tc qdisc del dev $IFACE root 2>/dev/null
  # 新しい遅延設定を追加
  sudo ip netns exec $SOURCE_CONTAINER tc qdisc add dev $IFACE root netem delay ${DELAY}ms
done

# ソースコンテナから宛先コンテナへpingを実行
docker exec $SOURCE_CONTAINER ping -c 4 $DEST_IP

# ネームスペースディレクトリを削除
sudo rm /var/run/netns/$SOURCE_CONTAINER
