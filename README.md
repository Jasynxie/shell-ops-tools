# 🛠️ Shell 运维脚本工具集

> 这些脚本是我在担任系统运维实习生期间，为解决实际运维问题而编写的工具集。所有脚本均经过测试，并在生产环境验证。

---

## 📁 核心工具列表

| 分类 | 脚本 | 核心功能 | 技术亮点 |
| :--- | :--- | :--- | :--- |
| **系统监控** | `disk_alert.sh` | 监控磁盘使用率，超过阈值时记录告警 | 支持自定义阈值（`-t`）、命令行参数解析、完整日志记录 |
| **日志管理** | `compress_old_logs.sh` | 查找并压缩指定天数前的日志文件 | 支持自定义天数（`-d`）、压缩后自动删除原文件 |
| **信息采集** | `system_info.sh` | 一键收集主机名、系统版本、内存、磁盘等信息 | 分类清晰输出、高使用率磁盘自动告警标记 |
| **文本处理** | `grep_pra.sh` | 过滤错误日志、剔除空行和注释行 | 组合过滤 + 扩展正则两种写法对比 |
| **文本处理** | `sed_pra.sh` | 批量修改配置参数、清理配置文件 | 自动备份原文件、多次编辑（`-e`） |
| **文本处理** | `awk_pra.sh` | 统计访问IP、筛选高使用率磁盘分区 | 自动生成示例日志、变量传递（`-v`） |
| **编码规范** | `Yange_pattern.sh` | 演示严格模式（`set -euo pipefail`）与错误处理 | 生产环境脚本编写规范参考 |

---

## 🚀 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/Jasynxie/shell-ops-tools.git

# 2. 进入目录
cd shell-ops-tools

# 3. 给所有脚本添加执行权限
chmod +x scripts/*/*.sh Yange_pattern.sh

# 4. 运行磁盘监控脚本（查看帮助）
./scripts/monitoring/disk_alert.sh -h

# 5. 运行磁盘监控脚本（使用默认阈值80%）
./scripts/monitoring/disk_alert.sh

# 6. 运行磁盘监控脚本（自定义阈值85%）
./scripts/monitoring/disk_alert.sh -t 85


# 📚 脚本使用示例

# disk_alert.sh

# 查看帮助
./scripts/monitoring/disk_alert.sh -h

# 使用默认阈值80%监控
./scripts/monitoring/disk_alert.sh

# 设置阈值为85%
./scripts/monitoring/disk_alert.sh -t 85


# ------------------------------------

# compress_old_logs.sh

# 查看帮助
./scripts/log-management/compress_old_logs.sh -h

# 压缩7天前的日志（默认）
./scripts/log-management/compress_old_logs.sh

# 压缩30天前的日志
./scripts/log-management/compress_old_logs.sh -d 30



# ----------------------------------------

# system_info.sh

# 查看帮助
./scripts/system-info/system_info.sh -h

# 收集当前主机信息
./scripts/system-info/system_info.sh



# ------------------------------------

# Yange_pattern.sh

# 查看帮助
./scripts/demo/Yange_pattern.sh -h

# 运行脚本，演示严格模式和错误处理
./scripts/demo/Yange_pattern.sh



## 📝 踩坑笔记

在编写这些脚本的过程中，我积累了一些常见问题与解决方案：

- **变量未定义导致脚本报错**
  - 原因：`set -u` 模式下未定义变量会触发退出
  - 解决：使用前先检查 `[ -z "$var" ]` 或设置默认值 `${var:-默认值}`

- **磁盘使用率提取后无法进行数值比较**
  - 原因：`df -h` 输出的使用率带 `%` 符号
  - 解决：使用 `sed 's/%//'` 或 `awk '{print $5+0}'` 去除 `%` 后再比较

- **管道命令失败但脚本继续运行**
  - 原因：默认情况下，管道中只有最后一个命令的退出码生效
  - 解决：使用 `set -o pipefail`，让管道中任何命令失败都算整体失败

- **find 配合 -exec 处理大量文件时失败**
  - 原因：参数列表过长，超过系统限制
  - 解决：使用 `xargs` 或 `find ... -exec {} +`（一次传递多个参数）

- **脚本重复执行导致冲突**
  - 原因：定时任务并发运行，多个实例同时操作同一资源
  - 解决：添加锁文件，用 `flock` 或 `mkdir` 实现互斥

- **Windows 编辑的脚本在 Linux 无法运行**
  - 原因：Windows 换行符是 `\r\n`，Linux 只认 `\n`
  - 解决：使用 `dos2unix` 转换，或在 VSCode 中设置换行符为 LF
