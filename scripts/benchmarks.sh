#!/bin/bash

###############################################################################
# Potter 基准测试脚本
# 特性: 实时进度、即时反馈
###############################################################################

# 配置
BENCHMARK_CASES=(
    "koios_dla_like_large_unrouted.phys"
    "mlcad_d181_lefttwo3rds_unrouted.phys"
    "ispd16_example2_unrouted.phys"
)
RUNS=3
THREADS=80
DEVICE="xcvu3p.device"

# MKL环境变量
export MKL_NUM_THREADS=1
export OMP_NUM_THREADS=1
export MKL_DYNAMIC=FALSE

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 查找可执行文件
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$PROJECT_ROOT/build/route" ]; then
    EXECUTABLE="$PROJECT_ROOT/build/route"
elif [ -f "$PROJECT_ROOT/route" ]; then
    EXECUTABLE="$PROJECT_ROOT/route"
else
    echo -e "${RED}错误: 找不到 route 可执行文件${NC}"
    exit 1
fi

# 查找benchmarks目录
if [ -d "$PROJECT_ROOT/benchmarks" ]; then
    BENCH_DIR="$PROJECT_ROOT/benchmarks"
elif [ -d "$PROJECT_ROOT/../benchmarks" ]; then
    BENCH_DIR="$PROJECT_ROOT/../benchmarks"
else
    echo -e "${RED}错误: 找不到 benchmarks 目录${NC}"
    exit 1
fi

# 结果文件
RESULT_FILE="$PROJECT_ROOT/benchmark_results.txt"
LOG_DIR="$PROJECT_ROOT/benchmark_logs"
mkdir -p "$LOG_DIR"

###############################################################################
# 执行函数 - 显示进度
###############################################################################
run_with_progress() {
    local cmd=$1
    local log_file=$2

    # 后台启动命令
    eval $cmd > "$log_file" 2>&1 &
    local pid=$!

    # 监控执行 - 显示进度
    local elapsed=0

    echo -e "${CYAN}  进度:${NC}" >&2

    while kill -0 $pid 2>/dev/null; do
        sleep 1
        elapsed=$((elapsed + 1))

        # 每5秒显示进度
        if [ $((elapsed % 5)) -eq 0 ]; then
            echo -e "  $(tail -2 "$log_file" 2>/dev/null | head -1 | cut -c1-80)" >&2
        fi
    done

    # 获取退出码
    wait $pid
    local exit_code=$?

    echo -e "${CYAN}  [完成: ${elapsed}s]${NC}" >&2
    return $exit_code
}

###############################################################################
# 从日志提取时间
###############################################################################
extract_time() {
    local log_file=$1
    local time=$(grep "Total route time:" "$log_file" 2>/dev/null | awk '{print $4}')

    if [ -z "$time" ]; then
        time=$(grep -E "time:.*[0-9]+\.[0-9]+" "$log_file" 2>/dev/null | tail -1 | grep -oE "[0-9]+\.[0-9]+")
    fi

    echo "$time"
}

###############################################################################
# 运行单个测试用例
###############################################################################
run_benchmark() {
    local case_name=$1
    local input_file="$BENCH_DIR/$case_name"
    local output_file="/tmp/potter_benchmark_output.phys"

    echo "" >&2
    echo -e "${BLUE}========================================${NC}" >&2
    echo -e "${GREEN}测试用例: $case_name${NC}" >&2
    echo -e "${BLUE}========================================${NC}" >&2

    if [ ! -f "$input_file" ]; then
        echo -e "${RED}错误: 找不到输入文件: $input_file${NC}" >&2
        return 1
    fi

    local times=()
    local failed_runs=0
    local sum=0

    for i in $(seq 1 $RUNS); do
        echo "" >&2
        echo -e "${YELLOW}--- Run $i/$RUNS ---${NC}" >&2

        local log_file="$LOG_DIR/${case_name%.phys}_run${i}.log"
        rm -f "$output_file"
        > "$log_file"

        local cmd="stdbuf -oL -eL $EXECUTABLE -i \"$input_file\" -o \"$output_file\" -d \"$DEVICE\" -t $THREADS"

        echo -e "${CYAN}启动测试...${NC}" >&2
        echo "" >&2

        if run_with_progress "$cmd" "$log_file"; then
            local route_time=$(extract_time "$log_file")

            if [ -n "$route_time" ] && [ "$route_time" != "0" ]; then
                times+=("$route_time")
                sum=$(awk -v s="$sum" -v t="$route_time" 'BEGIN {print s + t}')
                local avg=$(awk -v s="$sum" -v n="${#times[@]}" 'BEGIN {printf "%.2f", s / n}')

                echo "" >&2
                echo -e "${GREEN}✓ 成功: ${route_time}s${NC}" >&2
                echo -e "${CYAN}  当前平均: ${avg}s (${#times[@]} 次运行)${NC}" >&2
            else
                failed_runs=$((failed_runs + 1))
                echo "" >&2
                echo -e "${YELLOW}⚠ 警告: 无法从日志提取时间${NC}" >&2
                echo -e "${YELLOW}  日志: $log_file${NC}" >&2
            fi
        else
            local exit_code=$?
            failed_runs=$((failed_runs + 1))
            echo "" >&2
            echo -e "${RED}✗ 失败: 退出码 $exit_code${NC}" >&2
            echo -e "${RED}  日志: $log_file${NC}" >&2
        fi
    done

    # 显示最终结果
    echo "" >&2
    echo -e "${BLUE}========================================${NC}" >&2
    echo -e "${GREEN}结果汇总${NC}" >&2
    echo -e "${BLUE}========================================${NC}" >&2

    if [ ${#times[@]} -gt 0 ]; then
        local final_sum=0
        for time in "${times[@]}"; do
            final_sum=$(awk -v s="$final_sum" -v t="$time" 'BEGIN {print s + t}')
        done
        local avg=$(awk -v s="$final_sum" -v n="${#times[@]}" 'BEGIN {printf "%.2f", s / n}')

        echo -e "${GREEN}成功运行: ${#times[@]}/$RUNS${NC}" >&2
        echo -e "${GREEN}平均时间: ${avg}s${NC}" >&2

        if [ $failed_runs -gt 0 ]; then
            echo -e "${YELLOW}失败运行: $failed_runs${NC}" >&2
        fi

        # 写入结果文件
        {
            echo "$case_name:"
            echo "  运行: ${#times[@]}/$RUNS"
            for i in "${!times[@]}"; do
                echo "  Run $((i+1)): ${times[$i]}s"
            done
            echo "  平均: ${avg}s"
            if [ $failed_runs -gt 0 ]; then
                echo "  失败: $failed_runs"
            fi
            echo ""
        } >> "$RESULT_FILE"

        echo "$avg"
        return 0
    else
        echo -e "${RED}所有运行失败!${NC}" >&2
        echo "$case_name: 全部失败" >> "$RESULT_FILE"
        echo "" >> "$RESULT_FILE"
        echo "0"
        return 1
    fi
}

###############################################################################
# 主程序
###############################################################################
echo -e "${BLUE}======================================${NC}"
echo -e "${GREEN}Potter 基准测试${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "可执行文件: $EXECUTABLE"
echo -e "线程数: $THREADS"
echo -e "每用例运行次数: $RUNS"
echo -e "时间: $(date)"
echo -e "${BLUE}======================================${NC}"

# 初始化结果文件
{
    echo "======================================"
    echo "Potter 基准测试结果"
    echo "======================================"
    echo "可执行文件: $EXECUTABLE"
    echo "线程数: $THREADS"
    echo "运行次数: $RUNS"
    echo "时间: $(date)"
    echo "======================================"
    echo ""
} > "$RESULT_FILE"

# 运行所有测试
results=()
passed=0
total=${#BENCHMARK_CASES[@]}

for case in "${BENCHMARK_CASES[@]}"; do
    avg=$(run_benchmark "$case")
    results+=("$avg")
    if [ "$avg" != "0" ]; then
        passed=$((passed + 1))
    fi
done

# 最终汇总
echo ""
echo -e "${BLUE}======================================${NC}"
echo -e "${GREEN}最终汇总${NC}"
echo -e "${BLUE}======================================${NC}"

case_names=("koios" "mlcad" "ispd")
for i in "${!BENCHMARK_CASES[@]}"; do
    if [ "${results[$i]}" != "0" ]; then
        echo -e "${GREEN}${case_names[$i]}: ${results[$i]}s${NC}"
    else
        echo -e "${RED}${case_names[$i]}: 失败${NC}"
    fi
done

echo ""
echo -e "测试用例: $passed/$total 通过"
echo -e "结果文件: ${BLUE}$RESULT_FILE${NC}"
echo -e "日志目录: ${BLUE}$LOG_DIR/${NC}"
echo -e "${BLUE}======================================${NC}"

if [ $passed -eq $total ]; then
    echo -e "${GREEN}所有测试完成!${NC}"
    exit 0
else
    echo -e "${YELLOW}部分测试失败，查看日志了解详情${NC}"
    exit 1
fi
