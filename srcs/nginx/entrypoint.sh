#!/bin/sh
set -ex

# Create certificate
# -nodes: 鍵にパスフレーズを付けない（Nginxをパスフレーズ入力なしで起動したいなら実質必須／省くと起動時に困る）
# -x509: CSRではなく自己署名証明書を直接作る
# -subj "...": 対話プロンプトを避けるための非対話指定。CI/コンテナ内の自動生成なら実質必須
if [ ! -e /etc/ssl/private/inception.key ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/OU=42Tokyo/CN=inception" \
    -keyout /etc/ssl/private/inception.key \
    -out /etc/ssl/certs/inception.crt
fi

# Start nginx
exec nginx -g "daemon off;"
