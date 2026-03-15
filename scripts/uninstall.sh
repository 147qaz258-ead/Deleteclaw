#!/usr/bin/env bash

# OpenClaw 一键卸载脚本 (Unix/macOS/WSL)
# WARNING: 此脚本将删除所有 OpenClaw 数据和配置。

set -u

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🦞 OpenClaw 一键卸载工具${NC}"
echo -e "此脚本将卸载 OpenClaw 服务并删除所有本地数据 (~/.openclaw)。"
echo -e "${RED}警告：操作不可逆！${NC}"

# 确认操作
read -p "您确定要继续吗？(y/N) " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "卸载取消。"
    exit 0
fi

# 1. 停止并卸载系统服务
echo -e "\n${GREEN}==> 停止并卸载服务...${NC}"

# macOS (launchd)
if [[ "$OSTYPE" == "darwin"* ]]; then
    LABELS=("ai.openclaw.gateway" "ai.openclaw.node")
    DOMAIN="gui/$(id -u)"
    for label in "${LABELS[@]}"; do
        PLIST="$HOME/Library/LaunchAgents/$label.plist"
        if [ -f "$PLIST" ]; then
            echo "卸载 launchd 服务: $label"
            launchctl bootout "$DOMAIN" "$PLIST" 2>/dev/null
            launchctl unload "$PLIST" 2>/dev/null
            rm -f "$PLIST"
        fi
    done
fi

# Linux/WSL (systemd)
if command -v systemctl >/dev/null 2>&1; then
    SERVICES=("openclaw-gateway" "openclaw-node" "clawdbot-gateway" "moltbot-gateway")
    for service in "${SERVICES[@]}"; do
        if systemctl --user list-unit-files | grep -q "$service.service"; then
            echo "停止并禁用 systemd 服务: $service"
            systemctl --user stop "$service.service" 2>/dev/null
            systemctl --user disable "$service.service" 2>/dev/null
            rm -f "$HOME/.config/systemd/user/$service.service"
        fi
    done
    systemctl --user daemon-reload
fi

# 2. 清理 Docker 资源
echo -e "\n${GREEN}==> 清理 Docker 资源...${NC}"
if command -v docker >/dev/null 2>&1; then
    # 尝试在项目目录下执行 compose down (如果脚本在项目目录运行)
    if [ -f "docker-compose.yml" ]; then
        echo "通过 docker-compose 停止容器并移除卷..."
        docker compose down -v 2>/dev/null
    fi
    
    # 强制尝试移除常见名称的容器和卷
    echo "移除 OpenClaw 相关容器和镜像..."
    docker rm -f openclaw-gateway openclaw-cli 2>/dev/null
    docker volume rm openclaw_home openclaw_config openclaw_workspace 2>/dev/null
    
    # 提示清理镜像 (可选，通常不自动清理镜像以防用户想重装)
    echo -e "${YELLOW}提示: 如果需要删除 Docker 镜像，请通过 'docker rmi openclaw:local' 手动操作。${NC}"
fi

# 3. 删除本地数据目录
echo -e "\n${GREEN}==> 删除本地数据 (~/.openclaw)...${NC}"
OPENCLAW_DIR="$HOME/.openclaw"
if [ -d "$OPENCLAW_DIR" ]; then
    echo "正在删除 $OPENCLAW_DIR"
    rm -rf "$OPENCLAW_DIR"
else
    echo "未找到 $OPENCLAW_DIR 目录。"
fi

# 4. 提示卸载全局 NPM 包
echo -e "\n${GREEN}==> 完成!${NC}"
echo -e "大部分组件已清理完毕。"
echo -e "${YELLOW}最后一步，请根据您的包管理器执行以下命令手动卸载全局命令：${NC}"
echo -e "  npm uninstall -g openclaw"
echo -e "  或: pnpm remove -g openclaw"
echo -e "  或: bun remove -g openclaw"

echo -e "\n${GREEN}OpenClaw 已成功从您的系统中移除。${NC}"
