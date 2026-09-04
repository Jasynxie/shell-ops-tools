#!/bin/bash
# =============================================
# 脚本名称: compress_old_logs.sh
# 功能描述: 查找并压缩指定天数前的日志文件，压缩成功后删除原文件
# 作者:Jasyn
# 版本: 2.0 (支持自定义天数)
# 用法: ./compress_old_logs.sh [-d 天数] [-h]
# 示例: ./compress_old_logs.sh -d 7
# 输出: 控制台实时显示 + 日志文件记录
# =============================================

# 严格模式
set -euo pipefail

# =============================================
# 配置
# =============================================
LOG_DIR="."              # 默认扫描当前目录
DAYS=7                   # 默认7天前
ARCHIVE_DIR="./archives" # 压缩包存放目录
LOG_FILE="/tmp/logs/compress_$(date +%Y%m%d).log"

# =============================================
# 函数定义
# =============================================

# 显示帮助信息
show_help() {
    cat << EOF
用法: $0 [选项]

选项:
  -d, --days DAYS        设置过期天数（默认7天）
  -h, --help             显示此帮助信息

示例:
  $0                     使用默认7天
  $0 -d 30               查找并压缩30天前的日志
  $0 --days 14           查找并压缩14天前的日志

说明:
  脚本会查找指定目录下（默认当前目录）的 .log 文件，
  将超过指定天数的文件打包压缩到 ./archives/ 目录，
  压缩成功后删除原始文件。
EOF
    exit 0
}

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 错误处理函数
error_exit() {
    echo "错误: $1" >&2
    exit 2
}

# =============================================
# 解析命令行参数
# =============================================
while getopts "d:h" opt; do
    case $opt in
        d) DAYS="$OPTARG" ;;
        h) show_help ;;
        *) show_help ;;
    esac
done

# 检查天数是否合法（正整数）
if ! [[ "$DAYS" =~ ^[0-9]+$ ]] || [ "$DAYS" -lt 1 ]; then
    error_exit "天数必须是正整数，当前值: $DAYS"
fi

# =============================================
# 创建必要目录
# =============================================
mkdir -p "$ARCHIVE_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# =============================================
# 主程序
# =============================================
log "----------------------------------------"
log "开始查找并压缩 ${DAYS} 天前的日志文件"
log "日志目录: $LOG_DIR"
log "----------------------------------------"

# 检查日志目录是否存在
if [ ! -d "$LOG_DIR" ]; then
    error_exit "日志目录 $LOG_DIR 不存在"
fi

# 统计文件数量
file_count=$(find "$LOG_DIR" -type f -name "*.log" -mtime "+$DAYS" 2>/dev/null | wc -l)

if [ "$file_count" -eq 0 ]; then
    log "没有找到 ${DAYS} 天前的日志文件，无需处理"
    log "脚本执行结束"
    exit 0
fi

log "找到 ${file_count} 个过期日志文件"

# 生成压缩包文件名（带时间戳）
ARCHIVE_FILE="$ARCHIVE_DIR/logs_$(date +%Y%m%d_%H%M%S).tar.gz"

# 查找文件并打包压缩
log "开始压缩..."
if find "$LOG_DIR" -type f -name "*.log" -mtime "+$DAYS" -exec tar -czf "$ARCHIVE_FILE" {} + 2>/dev/null; then
    log "压缩成功: $ARCHIVE_FILE"
    log "压缩包大小: $(du -h "$ARCHIVE_FILE" | cut -f1)"
else
    error_exit "压缩失败"
fi

# 确认压缩成功后，删除原始文件
log "正在删除原始日志文件..."
if find "$LOG_DIR" -type f -name "*.log" -mtime "+$DAYS" -delete 2>/dev/null; then
    log "原始日志文件已删除，释放磁盘空间"
else
    error_exit "删除原始文件失败"
fi

log "----------------------------------------"
log "处理完成"
log "压缩包: $ARCHIVE_FILE"
log "日志文件: $LOG_FILE"
log "----------------------------------------"
