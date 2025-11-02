#!/bin/bash

#############################################
# Potter 快速基准测试脚本
# 用法: ./quick_benchmark.sh
# 输出: benchmark_results.txt
#############################################

set -e

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

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 查找可执行文件
if [ -f "build/route" ]; then
    EXECUTABLE="./build/route"
elif [ -f "./route" ]; then
    EXECUTABLE="./route"
else
    echo -e "${RED}错误: 找不到 route 可执行文件${NC}"
    exit 1
fi

# 查找benchmarks目录
if [ -d "benchmarks" ]; then
    BENCH_DIR="benchmarks"
elif [ -d "../benchmarks" ]; then
    BENCH_DIR="../benchmarks"
else
    echo -e "${RED}错误: 找不到 benchmarks 目录${NC}"
    exit 1
fi

# 创建结果文件
RESULT_FILE="benchmark_results.txt"
LOG_DIR="benchmark_logs"
mkdir -p "$LOG_DIR"

echo "======================================" | tee "$RESULT_FILE"
echo "Potter 基准测试结果" | tee -a "$RESULT_FILE"
echo "======================================" | tee -a "$RESULT_FILE"
echo "可执行文件: $EXECUTABLE" | tee -a "$RESULT_FILE"
echo "线程数: $THREADS" | tee -a "$RESULT_FILE"
echo "运行次数: $RUNS" | tee -a "$RESULT_FILE"
echo "时间: $(date)" | tee -a "$RESULT_FILE"
echo "======================================" | tee -a "$RESULT_FILE"
echo "" | tee -a "$RESULT_FILE"

# 测试函数
run_benchmark() {
    local case_name=$1
    local input_file="$BENCH_DIR/$case_name"
    local output_file="/tmp/potter_test_output.phys"

    echo -e "${BLUE}测试用例: $case_name${NC}"

    if [ ! -f "$input_file" ]; then
        echo -e "${RED}  错误: 找不到 $input_file${NC}"
        return 1
    fi

    local times=()

    for i in $(seq 1 $RUNS); do
        echo -n "  Run $i/$RUNS ... "

        local log_file="$LOG_DIR/${case_name%.phys}_run${i}.log"

        # 运行并捕获输出
        if $EXECUTABLE -i "$input_file" -o "$output_file" -d "$DEVICE" -t "$THREADS" > "$log_file" 2>&1; then
            # 提取路由时间
            local route_time=$(grep "Total route time:" "$log_file" | awk '{print $4}')

            if [ -n "$route_time" ]; then
                times+=("$route_time")
                echo -e "${GREEN}${route_time}s${NC}"
            else
                echo -e "${RED}失败 (未找到时间)${NC}"
            fi
        else
            echo -e "${RED}失败 (执行错误)${NC}"
        fi
    done

    # 计算平均值
    if [ ${#times[@]} -gt 0 ]; then
        local sum=0
        for time in "${times[@]}"; do
            sum=$(awk "BEGIN {print $sum + $time}")
        done
        local avg=$(awk "BEGIN {printf \"%.2f\", $sum / ${#times[@]}}")

        echo -e "${YELLOW}  平均时间: ${avg}s${NC}"
        echo ""

        # 写入结果文件
        echo "$case_name:" >> "$RESULT_FILE"
        for i in "${!times[@]}"; do
            echo "  Run $((i+1)): ${times[$i]}s" >> "$RESULT_FILE"
        done
        echo "  平均: ${avg}s" >> "$RESULT_FILE"
        echo "" >> "$RESULT_FILE"

        # 返回平均值供后续使用
        echo "$avg"
    else
        echo -e "${RED}  所有运行失败${NC}"
        echo "$case_name: 失败" >> "$RESULT_FILE"
        echo "" >> "$RESULT_FILE"
        echo "0"
    fi
}

# 运行所有测试
echo -e "${GREEN}开始基准测试...${NC}"
echo ""

results=()
for case in "${BENCHMARK_CASES[@]}"; do
    avg=$(run_benchmark "$case")
    results+=("$avg")
done

# 生成汇总
echo "======================================" | tee -a "$RESULT_FILE"
echo "汇总结果" | tee -a "$RESULT_FILE"
echo "======================================" | tee -a "$RESULT_FILE"

case_names=("koios" "mlcad" "ispd")
for i in "${!BENCHMARK_CASES[@]}"; do
    echo "${case_names[$i]}: ${results[$i]}s" | tee -a "$RESULT_FILE"
done

echo "" | tee -a "$RESULT_FILE"
echo -e "${GREEN}测试完成！${NC}"
echo -e "结果保存在: ${BLUE}$RESULT_FILE${NC}"
echo -e "日志保存在: ${BLUE}$LOG_DIR/${NC}"
