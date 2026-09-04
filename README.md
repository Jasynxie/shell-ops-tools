# Shell 运维脚本工具集

> 这些脚本是我在 **广州亚信技术有限公司** 担任系统运维实习生期间，为解决实际运维问题而编写的工具集。所有脚本均经过测试，并在生产环境验证。

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
```
