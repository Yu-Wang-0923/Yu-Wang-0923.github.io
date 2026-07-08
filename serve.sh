#!/bin/sh
# 本地开发：启动 Hugo 服务器（自动将 node_modules/.bin 加入 PATH）
cd "$(dirname "$0")"
PATH="$PWD/node_modules/.bin:$PATH" hugo server -D
