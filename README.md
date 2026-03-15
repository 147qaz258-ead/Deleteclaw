# 🦞 Deleteclaw: OpenClaw 一键完全卸载工具

这是一个为 [OpenClaw](https://github.com/openclaw/openclaw) 用户设计的独立卸载工具。它可以一键清理 OpenClaw 的所有残留，包括：

- **系统服务**: 自动停止并移除 systemd (Linux), launchd (macOS) 和计划任务 (Windows)。
- **Docker 资源**: 自动清理相关的容器和数据卷。
- **本地数据**: 彻底删除 `~/.openclaw` 目录（包含配置、对话记录、凭据和 Skills）。

## ⚡ 极速卸载 (最高优推荐)

为了让卸载变得最简单，我们准备了**双击即运行**的服务脚本：

### Windows 用户
1. 下载整个仓库或仅下载 `Double-click-to-uninstall.bat`。
2. **双击**运行 `Double-click-to-uninstall.bat` 即可。

### macOS / Linux 用户
1. 下载 `Double-click-to-uninstall.sh`。
2. 在终端运行 `chmod +x Double-click-to-uninstall.sh` (仅需一次)。
3. 此后只需**双击**该文件即可运行。

---

## 🛠️ 其他高级用法

### A. 命令行一键卸载 (适合开发者)
如果您习惯使用命令行，直接复制执行：

**Windows (PowerShell):**
```powershell
iwr -useb https://raw.githubusercontent.com/147qaz258-ead/Deleteclaw/main/scripts/uninstall.ps1 | iex
```

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/147qaz258-ead/Deleteclaw/main/scripts/uninstall.sh | bash
```

### B. 使用 npx 运行
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
