#!/bin/bash

###############################################################################
# VTune 权限设置脚本
# 解决 ptrace 和采样驱动权限问题
###############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}       Intel VTune 权限配置${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo ""

# 检查是否有 sudo 权限
if ! sudo -v; then
    echo -e "${RED}错误: 需要 sudo 权限来配置 VTune${NC}"
    exit 1
fi

echo -e "${BLUE}[1/3] 配置 ptrace 权限...${NC}"

# 临时设置（立即生效，重启后失效）
current_ptrace=$(cat /proc/sys/kernel/yama/ptrace_scope)
echo -e "当前 ptrace_scope: ${YELLOW}${current_ptrace}${NC}"

if [ "$current_ptrace" != "0" ]; then
    echo -e "${YELLOW}设置 ptrace_scope 为 0 (临时，重启后恢复)...${NC}"
    sudo sysctl -w kernel.yama.ptrace_scope=0
    echo -e "${GREEN}✓ ptrace_scope 已设置为 0${NC}"
else
    echo -e "${GREEN}✓ ptrace_scope 已经是 0${NC}"
fi

echo ""
echo -e "${BLUE}[2/3] 检查 VTune 采样驱动...${NC}"

# 检查采样驱动是否加载
if lsmod | grep -q "sep5\|vtsspp"; then
    echo -e "${GREEN}✓ VTune 采样驱动已加载${NC}"
else
    echo -e "${YELLOW}尝试加载 VTune 采样驱动...${NC}"

    # 查找 VTune 驱动安装脚本
    VTUNE_DRIVER_SCRIPT=""
    POSSIBLE_PATHS=(
        "/opt/intel/oneapi/vtune/latest/sepdk/src/insmod-sep"
        "/opt/intel/oneapi/vtune/2025.4/sepdk/src/insmod-sep"
        "/opt/intel/oneapi/vtune/2025/sepdk/src/insmod-sep"
    )

    for path in "${POSSIBLE_PATHS[@]}"; do
        if [ -f "$path" ]; then
            VTUNE_DRIVER_SCRIPT="$path"
            break
        fi
    done

    if [ -n "$VTUNE_DRIVER_SCRIPT" ]; then
        echo -e "${CYAN}找到驱动脚本: $VTUNE_DRIVER_SCRIPT${NC}"
        sudo "$VTUNE_DRIVER_SCRIPT" || {
            echo -e "${YELLOW}警告: 驱动加载失败，但可以继续（使用用户模式）${NC}"
        }
    else
        echo -e "${YELLOW}警告: 未找到 VTune 驱动脚本${NC}"
        echo -e "${YELLOW}VTune 将使用用户模式运行（功能受限但可用）${NC}"
    fi
fi

echo ""
echo -e "${BLUE}[3/3] 验证配置...${NC}"

echo -e "ptrace_scope: $(cat /proc/sys/kernel/yama/ptrace_scope)"

if lsmod | grep -q "sep5\|vtsspp"; then
    echo -e "${GREEN}✓ VTune 驱动: 已加载${NC}"
else
    echo -e "${YELLOW}! VTune 驱动: 未加载（将使用用户模式）${NC}"
fi

echo ""
echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}       配置完成!${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo ""
echo -e "${GREEN}现在可以运行 VTune 分析:${NC}"
echo -e "  ${YELLOW}./scripts/vtune_analysis.sh -t hotspots${NC}"
echo ""
echo -e "${CYAN}注意:${NC}"
echo -e "  - ptrace_scope 设置是临时的，重启后会恢复"
echo -e "  - 如需永久设置，编辑 /etc/sysctl.d/10-ptrace.conf"
echo -e "  - 即使驱动未加载，VTune 也可以在用户模式下工作"
echo ""
