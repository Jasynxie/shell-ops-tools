#!/bin/bash
# =============================================
# 脚本名称: system_info.sh
# 功能描述: 一键收集主机基础信息（主机名、系统版本、内存、磁盘等）
# 作者: 谢Jasyn
# 版本: 2.0 (优化输出格式，增加更多信息项)
# 用法: ./system_info.sh [-h]
# 示例: ./system_info.sh
# 输出: 控制台打印格式化报告
# =============================================

# =============================================
# 函数定义
# =============================================

# 显示帮助信息
show_help() {
    cat << EOF
用法: $0 [选项]

选项:
  -h, --help             显示此帮助信息

示例:
  $0                     收集当前主机的基础信息

说明:
  脚本会收集以下信息：
  - 主机名
  - 操作系统版本
  - 内核版本
  - 内存使用情况（总量/已用/可用）
  - 磁盘使用情况（各分区使用率）
  - 当前登录用户
  - 系统运行时间
  - 系统负载
EOF
    exit 0
}

# =============================================
# 解析命令行参数
# =============================================
while getopts "h" opt; do
    case $opt in
        h) show_help ;;
        *) show_help ;;
    esac
done

# =============================================
# 主程序
# =============================================

# 设置时区
export TZ='Asia/Shanghai'

# 输出报告标题
echo "================================"
echo "        主机基础信息报告"
echo "  报告生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "================================"
echo ""

# 1. 主机名
echo "[主机信息]"
echo "  主机名: $(hostname)"
echo ""

# 2. 系统版本
echo "[系统信息]"
if [ -f /etc/os-release ]; then
    echo "  操作系统: $(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)"
    echo "  系统版本: $(grep '^VERSION_ID=' /etc/os-release | cut -d'"' -f2)"
else
    echo "  操作系统: $(uname -s)"
fi
echo "  内核版本: $(uname -r)"
echo "  架构: $(uname -m)"
echo ""

# 3. 内存使用情况
echo "[内存信息]"
free -h | grep -E "Mem|Swap" | while read line; do
    echo "  $line"
done
echo ""

# 4. 磁盘使用情况
echo "[磁盘信息]"
df -h | head -1
df -h | grep -v "Filesystem" | while read line; do
    usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
    if [ -n "$usage" ] && [ "$usage" -ge 80 ] 2>/dev/null; then
        echo "  ⚠️ $line"  # 高使用率加警告标记
    else
        echo "  $line"
    fi
done
echo ""

# 5. 当前登录用户
echo "[登录信息]"
echo "  当前用户: $(whoami)"
echo "  登录用户数: $(who | wc -l)"
if [ "$(who | wc -l)" -gt 0 ]; then
    echo "  在线用户列表:"
    who | awk '{print "    " $1 " - " $3 " " $4}' | sort -u
fi
echo ""

# 6. 系统运行时间
echo "[运行状态]"
echo "  运行时间: $(uptime -p 2>/dev/null | sed 's/up //' || uptime | awk '{print $3,$4}')"
echo "  系统负载: $(uptime | awk -F'load average:' '{print $2}' | xargs)"
echo ""

echo "================================"
echo "报告生成完毕"
echo "================================"
