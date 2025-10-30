#!/bin/bash

###############################################################################
# Potter 性能基准测试脚本
# 用途: 对比优化前后的性能提升
# 作者: Claude Code
# 日期: 2025-10-30
###############################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
EXECUTABLE="${BUILD_DIR}/route"
BENCHMARK_DIR="${PROJECT_ROOT}/benchmarks"
RESULTS_DIR="${PROJECT_ROOT}/benchmark_results"
THREADS=80

# 测试用例
BENCHMARK_CASES=(
    "koios_dla_like_large_unrouted.phys"
    "mlcad_d181_lefttwo3rds_unrouted.phys"
    "ispd16_example2_unrouted.phys"
)

###############################################################################
# 函数: 打印帮助信息
###############################################################################
print_usage() {
    cat << EOF
${GREEN}Potter 性能基准测试脚本${NC}

用法: $0 [选项]

选项:
    -t, --threads NUM    线程数 (默认: 80)
    -r, --runs NUM       每个测试运行次数 (默认: 3)
    -c, --case CASE      只运行指定测试用例
    -h, --help           显示帮助信息

示例:
    # 运行所有测试用例，每个3次
    $0

    # 只运行 koios 测试用例，5次取平均
    $0 -c koios_dla_like_large_unrouted.phys -r 5

    # 使用 40 线程
    $0 -t 40

EOF
}

###############################################################################
# 函数: 运行单个测试
###############################################################################
run_single_test() {
    local test_case=$1
    local run_id=$2
    local result_file=$3

    local test_path="${BENCHMARK_DIR}/${test_case}"
    local output_path="${RESULTS_DIR}/output_${run_id}.phys"

    if [ ! -f "$test_path" ]; then
        echo -e "${RED}错误: 测试用例不存在 - $test_case${NC}"
        return 1
    fi

    echo -e "${CYAN}  运行 ${run_id}...${NC}"

    # 使用 /usr/bin/time 获取详细时间信息
    /usr/bin/time -f "Elapsed: %E\nUser: %U\nSystem: %S\nMaxRSS: %M KB" \
        "$EXECUTABLE" \
        -i "$test_path" \
        -o "$output_path" \
        -t "$THREADS" \
        > "${result_file}" 2>&1

    # 提取路由时间
    local route_time=$(grep "Total route time:" "${result_file}" | awk '{print $4}')
    local elapsed_time=$(grep "Elapsed:" "${result_file}" | awk '{print $2}')

    echo "$route_time $elapsed_time"
}

###############################################################################
# 函数: 运行基准测试
###############################################################################
run_benchmark() {
    local test_case=$1
    local num_runs=$2

    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${GREEN}测试用例: $(basename $test_case .phys)${NC}"
    echo -e "${BLUE}======================================================================${NC}"

    # 创建结果目录
    local case_name=$(basename "$test_case" .phys)
    local case_result_dir="${RESULTS_DIR}/${case_name}"
    mkdir -p "$case_result_dir"

    # 运行多次测试
    local total_route_time=0
    local total_elapsed_time=0
    local valid_runs=0

    for i in $(seq 1 $num_runs); do
        local result_file="${case_result_dir}/run_${i}.log"

        # 运行测试
        local times=$(run_single_test "$test_case" $i "$result_file")

        if [ $? -eq 0 ]; then
            local route_time=$(echo $times | awk '{print $1}')
            local elapsed_time=$(echo $times | awk '{print $2}')

            # 转换时间为秒（从 MM:SS 格式）
            if [[ $elapsed_time == *:* ]]; then
                local mins=$(echo $elapsed_time | cut -d: -f1)
                local secs=$(echo $elapsed_time | cut -d: -f2)
                elapsed_time=$(echo "$mins * 60 + $secs" | bc)
            fi

            total_route_time=$(echo "$total_route_time + $route_time" | bc)
            total_elapsed_time=$(echo "$total_elapsed_time + $elapsed_time" | bc)
            valid_runs=$((valid_runs + 1))

            echo -e "${GREEN}    ✓ 路由时间: ${route_time}s, 总耗时: ${elapsed_time}s${NC}"
        else
            echo -e "${YELLOW}    ⚠ 运行 $i 失败${NC}"
        fi
    done

    # 计算平均值
    if [ $valid_runs -gt 0 ]; then
        local avg_route_time=$(echo "scale=2; $total_route_time / $valid_runs" | bc)
        local avg_elapsed_time=$(echo "scale=2; $total_elapsed_time / $valid_runs" | bc)

        echo -e ""
        echo -e "${GREEN}平均路由时间: ${avg_route_time}s${NC}"
        echo -e "${GREEN}平均总耗时: ${avg_elapsed_time}s${NC}"
        echo -e "${GREEN}有效运行: ${valid_runs}/${num_runs}${NC}"

        # 保存结果
        cat > "${case_result_dir}/summary.txt" << EOF
Test Case: ${case_name}
Threads: ${THREADS}
Runs: ${valid_runs}/${num_runs}
Average Route Time: ${avg_route_time}s
Average Total Time: ${avg_elapsed_time}s
EOF

        echo "$avg_route_time" > "${case_result_dir}/avg_route_time.txt"
        echo "$avg_elapsed_time" > "${case_result_dir}/avg_total_time.txt"
    else
        echo -e "${RED}所有运行都失败了！${NC}"
        return 1
    fi

    echo ""
}

###############################################################################
# 函数: 生成对比报告
###############################################################################
generate_comparison_report() {
    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${GREEN}生成性能对比报告${NC}"
    echo -e "${BLUE}======================================================================${NC}"

    local report_file="${RESULTS_DIR}/PERFORMANCE_REPORT.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    cat > "$report_file" << EOF
# Potter 性能基准测试报告

**测试时间**: ${timestamp}
**线程数**: ${THREADS}
**服务器**: Ubuntu + Intel 80核心

---

## 测试结果

| 测试用例 | 平均路由时间 | 平均总耗时 | 运行次数 |
|---------|------------|----------|---------|
EOF

    for case in "${BENCHMARK_CASES[@]}"; do
        local case_name=$(basename "$case" .phys)
        local case_result_dir="${RESULTS_DIR}/${case_name}"

        if [ -f "${case_result_dir}/avg_route_time.txt" ]; then
            local avg_route=$(cat "${case_result_dir}/avg_route_time.txt")
            local avg_total=$(cat "${case_result_dir}/avg_total_time.txt")
            local summary=$(grep "Runs:" "${case_result_dir}/summary.txt" | awk '{print $2}')

            echo "| ${case_name} | ${avg_route}s | ${avg_total}s | ${summary} |" >> "$report_file"
        fi
    done

    cat >> "$report_file" << EOF

---

## 测试环境

- **编译器**: Intel icpx (oneAPI 2025)
- **优化选项**: -O3 -march=native -qopenmp
- **oneMKL**: 已启用
- **构建类型**: RelWithDebInfo

---

## 优化内容

### 已实施的优化：

1. **原子操作优化** (预期 30-40% 提升)
   - 使用 \`memory_order_relaxed\` 降低原子操作开销
   - \`getOccupancy()\` 是最大热点（mlcad 测试 54.4% CPU 时间）

2. **Vector 预分配** (预期 5-10% 提升)
   - RouteNode children vector 预分配 8 个元素
   - 避免频繁的内存重新分配和拷贝

3. **NodeInfo 对象重用** (预期 5-8% 提升)
   - 添加高效的 reset() 方法
   - 避免重复构造 2800 万个对象

**预期总提升**: 40-58%

---

## 如何对比优化前后

如果您保存了优化前的测试结果，可以计算提升：

\`\`\`
性能提升 % = (优化前时间 - 优化后时间) / 优化前时间 × 100%
\`\`\`

---

## 详细日志

每次运行的详细日志保存在:
\`\`\`
benchmark_results/<test_case>/run_*.log
\`\`\`

**生成时间**: ${timestamp}
EOF

    echo -e "${GREEN}✓ 报告已生成: ${report_file}${NC}"
}

###############################################################################
# 主程序
###############################################################################
main() {
    local num_runs=3
    local specific_case=""

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--threads)
                THREADS="$2"
                shift 2
                ;;
            -r|--runs)
                num_runs="$2"
                shift 2
                ;;
            -c|--case)
                specific_case="$2"
                shift 2
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                echo -e "${RED}未知选项: $1${NC}"
                print_usage
                exit 1
                ;;
        esac
    done

    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${GREEN}       Potter 性能基准测试${NC}"
    echo -e "${BLUE}======================================================================${NC}"
    echo ""
    echo -e "${CYAN}配置:${NC}"
    echo -e "  线程数: ${THREADS}"
    echo -e "  运行次数: ${num_runs}"
    echo -e "  可执行文件: ${EXECUTABLE}"
    echo ""

    # 检查可执行文件
    if [ ! -f "$EXECUTABLE" ]; then
        echo -e "${RED}错误: 未找到可执行文件 - $EXECUTABLE${NC}"
        echo -e "${YELLOW}请先编译项目:${NC}"
        echo -e "  cmake --build build -j 80"
        exit 1
    fi

    # 创建结果目录
    mkdir -p "$RESULTS_DIR"

    # 运行测试
    if [ -n "$specific_case" ]; then
        # 只运行指定的测试用例
        run_benchmark "$specific_case" "$num_runs"
    else
        # 运行所有测试用例
        for case in "${BENCHMARK_CASES[@]}"; do
            run_benchmark "$case" "$num_runs"
        done
    fi

    # 生成报告
    generate_comparison_report

    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${GREEN}       测试完成!${NC}"
    echo -e "${BLUE}======================================================================${NC}"
    echo ""
    echo -e "查看报告:"
    echo -e "  ${YELLOW}cat ${RESULTS_DIR}/PERFORMANCE_REPORT.md${NC}"
    echo ""
}

# 运行主程序
main "$@"
