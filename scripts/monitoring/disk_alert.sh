#!/bin/bash
# =============================================
# 脚本名称: disk_alert.sh
# 功能描述: 监控磁盘使用率，超过阈值时记录告警
# 作者: Jasyn
# 版本: 2.0 (支持自定义阈值)
# 用法: ./disk_alert.sh [-t 阈值] [-h]
# 示例: ./disk_alert.sh -t 85
# 输出: 控制台实时显示 + 日志文件记录
# =============================================

# 严格模式
set -euo pipefail

# =============================================
# 配置
# =============================================
THRESHOLD=80  # 默认阈值
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/disk_alert_$(date +%Y%m%d).log"
ALERT_FILE="$LOG_DIR/disk_alert_$(date +%Y%m%d).alert"

# =============================================
# 函数定义
# =============================================

# 显示帮助信息
show_help() {
    cat << EOF
用法: $0 [选项]

选项:
  -t, --threshold THRESHOLD   设置告警阈值 (百分比，默认80)
  -h, --help                  显示此帮助信息

示例:
  $0                         使用默认阈值80%监控
  $0 -t 85                   设置阈值为85%
  $0 --threshold 90          设置阈值为90%

说明:
  阈值必须是 0-100 之间的数字。
  当任何磁盘分区的使用率 >= 阈值时，会触发告警。
EOF
    exit 0
}

# 日志函数（带时间戳）
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 输出函数（不带时间戳）
print() {
    echo "$1" | tee -a "$LOG_FILE"
}

# 告警函数
alert() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ $1" | tee -a "$LOG_FILE" >> "$ALERT_FILE"
}

# 错误处理函数
error_exit() {
    echo "错误: $1" >&2
    exit 2
}

# =============================================
# 解析命令行参数
# =============================================
while getopts "t:h" opt; do
    case $opt in
        t) THRESHOLD="$OPTARG" ;;
        h) show_help ;;
        *) show_help ;;
    esac
done

# 检查阈值是否合法（0-100之间的数字）
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || [ "$THRESHOLD" -lt 0 ] || [ "$THRESHOLD" -gt 100 ]; then
    error_exit "阈值必须是 0-100 之间的数字，当前值: $THRESHOLD"
fi

# =============================================
# 创建日志目录
# =============================================
mkdir -p "$LOG_DIR"

# =============================================
# 主程序
# =============================================
log "----------------------------------------"
log "磁盘使用率告警脚本开始执行"
log "告警阈值：${THRESHOLD}%"
log "----------------------------------------"

print ""
print "磁盘使用率监控报告"
print "生成时间：$(date '+%Y-%m-%d %H:%M:%S')"
print "告警阈值：${THRESHOLD}%"
print "----------------------------------------"

alert_count=0

# 逐行读取磁盘信息
df -h | while read line; do
    # 跳过标题行
    if echo "$line" | grep -q "Filesystem"; then
        continue
    fi

    # 提取使用率和挂载点
    usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
    mount_point=$(echo "$line" | awk '{print $6}')

    # 跳过异常行（非数字）
    if ! [[ "$usage" =~ ^[0-9]+$ ]]; then
        continue
    fi

    # 显示每个分区的使用情况
    print "$mount_point 使用率：${usage}%"

    # 检查是否超过阈值
    if [ "$usage" -ge "$THRESHOLD" ]; then
        alert_msg="$mount_point 使用率已达 ${usage}%，超过阈值 ${THRESHOLD}%"
        alert "$alert_msg"
        alert_count=$((alert_count + 1))
    fi
done

print ""
print "----------------------------------------"
print "监控完成"
print "告警数量：${alert_count}"
print "日志文件：${LOG_FILE}"
print "告警文件：${ALERT_FILE}"
print "----------------------------------------"

log "脚本执行结束"
