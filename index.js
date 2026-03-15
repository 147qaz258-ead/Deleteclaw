#!/usr/bin/env node

import { execSync } from 'node:child_process';
import os from 'node:os';
import path from 'node:path';
import fs from 'node:fs';
import { program } from 'commander';
import chalk from 'chalk';
import prompts from 'prompts';

program
  .name('deleteclaw')
  .description('One-click uninstaller for OpenClaw')
  .version('1.0.0')
  .option('--dry-run', 'List actions without performing them')
  .option('--force', 'Uninstall without confirmation')
  .parse(process.argv);

const options = program.opts();

async function run() {
  console.log(chalk.yellow('\n🦞 OpenClaw 一键卸载工具 (Standalone)'));
  console.log('此工具将彻底移除 OpenClaw 服务、Docker 资源和所有本地数据。\n');

  if (!options.force && !options.dryRun) {
    const response = await prompts({
      type: 'confirm',
      name: 'value',
      message: chalk.red('您确定要彻底卸载 OpenClaw 吗？所有对话记录和配置将被删除！'),
      initial: false
    });

    if (!response.value) {
      console.log('卸载已取消。');
      process.exit(0);
    }
  }

  const isWin = os.platform() === 'win32';
  const isMac = os.platform() === 'darwin';
  const isLinux = os.platform() === 'linux';
  const home = os.homedir();

  // 1. 停止服务
  console.log(chalk.green('==> 1. 停止并移除系统服务...'));
  if (isWin) {
    const tasks = ['OpenClaw Gateway', 'OpenClaw Node'];
    for (const task of tasks) {
      execute(`schtasks /Delete /TN "${task}" /F`, `移除计划任务: ${task}`, true);
    }
  } else if (isMac) {
    const labels = ['ai.openclaw.gateway', 'ai.openclaw.node'];
    const domain = `gui/${process.getuid?.() || 501}`;
    for (const label of labels) {
      const plist = path.join(home, 'Library/LaunchAgents', `${label}.plist`);
      if (fs.existsSync(plist)) {
        execute(`launchctl bootout ${domain} "${plist}"`, `停止服务: ${label}`, true);
        execute(`launchctl unload "${plist}"`, `注销服务: ${label}`, true);
        execute(`rm -f "${plist}"`, `删除配置文件: ${plist}`);
      }
    }
  } else if (isLinux) {
    const services = ['openclaw-gateway', 'openclaw-node', 'clawdbot-gateway', 'moltbot-gateway'];
    for (const service of services) {
      execute(`systemctl --user stop ${service}.service`, `停止服务: ${service}`, true);
      execute(`systemctl --user disable ${service}.service`, `禁用服务: ${service}`, true);
      const unitPath = path.join(home, '.config/systemd/user', `${service}.service`);
      if (fs.existsSync(unitPath)) {
        execute(`rm -f "${unitPath}"`, `删除服务文件: ${unitPath}`);
      }
    }
    execute('systemctl --user daemon-reload', '刷新 systemd 守护进程', true);
  }

  // 2. 清理 Docker
  console.log(chalk.green('\n==> 2. 清理 Docker 资源...'));
  if (commandExists('docker')) {
    execute('docker rm -f openclaw-gateway openclaw-cli', '删除 OpenClaw 容器', true);
    execute('docker volume rm openclaw_home openclaw_config openclaw_workspace', '删除 OpenClaw 数据卷', true);
  } else {
    console.log('未检测到 Docker，跳过。');
  }

  // 3. 删除本地数据
  console.log(chalk.green('\n==> 3. 清理本地数据目录...'));
  const openclawDir = path.join(home, '.openclaw');
  if (fs.existsSync(openclawDir)) {
    execute(isWin ? `rmdir /s /q "${openclawDir}"` : `rm -rf "${openclawDir}"`, `删除目录: ${openclawDir}`);
  } else {
    console.log('未发现 ~/.openclaw 目录。');
  }

  console.log(chalk.bold.green('\n✨ 卸载完成！'));
  console.log(chalk.cyan('如果您还安装了全局 NPM 包，请运行：'));
  console.log('   npm uninstall -g openclaw\n');
}

function execute(cmd, description, ignoreError = false) {
  if (options.dryRun) {
    console.log(chalk.gray(`[模拟] ${description}: ${cmd}`));
    return;
  }
  try {
    process.stdout.write(`${description}... `);
    execSync(cmd, { stdio: 'ignore' });
    console.log(chalk.green('成功'));
  } catch (err) {
    if (ignoreError) {
      console.log(chalk.gray('跳过 (可能已不存在)'));
    } else {
      console.log(chalk.red('失败'));
    }
  }
}

function commandExists(cmd) {
  try {
    const checkCmd = os.platform() === 'win32' ? `where ${cmd}` : `command -v ${cmd}`;
    execSync(checkCmd, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

run().catch(err => {
  console.error(chalk.red('\n错误:'), err.message);
  process.exit(1);
});
