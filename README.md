# 🦞 Deleteclaw: OpenClaw 一键完全卸载工具

这是一个为 [OpenClaw](https://github.com/openclaw/openclaw) 用户设计的独立卸载工具。它可以一键清理 OpenClaw 的所有残留，包括：

- **系统服务**: 自动停止并移除 systemd (Linux), launchd (macOS) 和计划任务 (Windows)。
- **Docker 资源**: 自动清理相关的容器和数据卷。
- **本地数据**: 彻底删除 `~/.openclaw` 目录（包含配置、对话记录、凭据和 Skills）。

## 🚀 使用方法

### 直接运行 (推荐)

在该工具的 [Releases](https://github.com/147qaz258-ead/Deleteclaw/releases) 页面下载适合您系统的二进制文件，然后在终端运行：

**Windows:**
```powershell
.\deleteclaw-win.exe
```

**macOS / Linux:**
```bash
chmod +x deleteclaw-macos # 或 deleteclaw-linux
./deleteclaw-macos
```

### 使用 Node.js 运行

如果您已安装 Node.js，也可以直接通过 npm 运行：

```bash
npx deleteclaw
```

## ⚠️ 警告

卸载操作将删除所有对话历史和配置。**此操作不可逆**，请在执行前确保已备份重要数据。

## 🛠️ 构建说明

如果您想从源码构建：

1. 克隆仓库: `git clone https://github.com/147qaz258-ead/Deleteclaw.git`
2. 安装依赖: `npm install`
3. 执行构建: `npm run build`

构建产物将存放在 `dist` 目录中。

## 开源协议

MIT
