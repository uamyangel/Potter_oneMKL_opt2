#!/bin/bash

###############################################################################
# Intel VTune 性能分析脚本 for Potter
# 用途: 深度性能分析，识别 CPU 热点、内存瓶颈、线程效率问题
# 作者: Claude Code
# 日期: 2025-10-30
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
EXECUTABLE="${BUILD_DIR}/route"  # 实际可执行文件名是 route
VTUNE_RESULTS_DIR="${PROJECT_ROOT}/vtune_results"
ANALYSIS_TYPE="hotspots"  # 默认分析类型
THREADS=80  # 默认线程数

# 基准测试用例
BENCHMARK_DIR="${PROJECT_ROOT}/benchmarks"
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
${GREEN}Intel VTune 性能分析脚本 for Potter${NC}

用法: $0 [选项]

选项:
    -t, --type TYPE         分析类型 (默认: hotspots)
                            可选: hotspots, memory-access, threading,
                                  uarch-exploration, all
    -j, --threads NUM       线程数 (默认: 80)
    -b, --benchmark CASE    指定基准测试用例 (默认: 运行所有)
    -o, --output DIR        输出目录 (默认: vtune_results)
    -c, --clean             清理旧的分析结果
    -h, --help              显示帮助信息

分析类型说明:
    hotspots              - CPU 热点分析 (最常用)
                            识别耗时最多的函数和代码行

    memory-access         - 内存访问分析
                            分析内存带宽、缓存未命中率、DTLB 未命中

    threading             - 线程分析
                            分析线程效率、同步开销、负载均衡

    uarch-exploration     - 微架构探索
                            分析前端停顿、后端停顿、分支预测失败

    all                   - 运行所有分析类型 (耗时最长)

示例:
    # 运行 CPU 热点分析
    $0 -t hotspots

    # 运行内存访问分析
    $0 -t memory-access

    # 对特定用例运行线程分析
    $0 -t threading -b koios_dla_like_large.phys

    # 运行完整分析套件
    $0 -t all

EOF
}

###############################################################################
# 函数: 检查 VTune 是否安装
###############################################################################
check_vtune() {
    echo -e "${BLUE}[1/6] 检查 Intel VTune 安装...${NC}"

    # 检查 vtune 命令是否存在
    if ! command -v vtune &> /dev/null; then
        echo -e "${YELLOW}未找到 vtune 命令，尝试加载 Intel 环境...${NC}"

        # 常见的 Intel oneAPI 安装路径
        POSSIBLE_PATHS=(
            "/opt/intel/oneapi/setvars.sh"
            "$HOME/intel/oneapi/setvars.sh"
            "/opt/intel/vtune/latest/vtune-vars.sh"
        )

        FOUND=0
        for path in "${POSSIBLE_PATHS[@]}"; do
            if [ -f "$path" ]; then
                echo -e "${GREEN}找到 Intel 环境: $path${NC}"
                source "$path" > /dev/null 2>&1
                FOUND=1
                break
            fi
        done

        if [ $FOUND -eq 0 ]; then
            echo -e "${RED}错误: 未找到 Intel VTune!${NC}"
            echo -e "${YELLOW}请先安装 Intel VTune Profiler:${NC}"
            echo "  1. 下载 Intel oneAPI Base Toolkit: https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html"
            echo "  2. 安装后运行: source /opt/intel/oneapi/setvars.sh"
            echo "  3. 或者单独安装 VTune: https://www.intel.com/content/www/us/en/developer/tools/oneapi/vtune-profiler.html"
            exit 1
        fi
    fi

    # 验证 vtune 命令
    if command -v vtune &> /dev/null; then
        VTUNE_VERSION=$(vtune --version 2>&1 | head -n1)
        echo -e "${GREEN}✓ Intel VTune 已安装: $VTUNE_VERSION${NC}"
    else
        echo -e "${RED}错误: 加载 Intel 环境后仍无法找到 vtune 命令${NC}"
        exit 1
    fi
}

###############################################################################
# 函数: 检查可执行文件
###############################################################################
check_executable() {
    echo -e "${BLUE}[2/6] 检查可执行文件...${NC}"

    if [ ! -f "$EXECUTABLE" ]; then
        echo -e "${YELLOW}未找到可执行文件: $EXECUTABLE${NC}"
        echo -e "${YELLOW}正在编译 Potter (带调试符号)...${NC}"

        # 使用带调试符号的编译选项
        cd "$PROJECT_ROOT"
        mkdir -p "$BUILD_DIR"
        cd "$BUILD_DIR"

        cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              -DCMAKE_CXX_COMPILER=icpx \
              -DCMAKE_C_COMPILER=icx \
              -DCMAKE_CXX_FLAGS="-O3 -g -march=native -qopenmp" \
              ..

        make -j $(nproc)

        if [ ! -f "$EXECUTABLE" ]; then
            echo -e "${RED}错误: 编译失败!${NC}"
            exit 1
        fi

        echo -e "${GREEN}✓ 编译完成${NC}"
    else
        echo -e "${GREEN}✓ 找到可执行文件: $EXECUTABLE${NC}"
    fi
}

###############################################################################
# 函数: 准备分析环境
###############################################################################
prepare_environment() {
    echo -e "${BLUE}[3/6] 准备分析环境...${NC}"

    # 创建结果目录
    mkdir -p "$VTUNE_RESULTS_DIR"

    # 检查基准测试文件
    echo -e "检查基准测试用例..."
    for case in "${BENCHMARK_CASES[@]}"; do
        FULL_PATH="$BENCHMARK_DIR/$case"
        if [ ! -f "$FULL_PATH" ]; then
            echo -e "${YELLOW}警告: 未找到测试用例 $case${NC}"
        else
            echo -e "${GREEN}  ✓ $case${NC}"
        fi
    done

    echo -e "${GREEN}✓ 环境准备完成${NC}"
}

###############################################################################
# 函数: 运行 VTune 分析
###############################################################################
run_vtune_analysis() {
    local analysis_type=$1
    local benchmark_case=$2
    local result_name="${analysis_type}_$(basename $benchmark_case .phys)"
    local result_dir="${VTUNE_RESULTS_DIR}/${result_name}"

    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${GREEN}运行 VTune 分析${NC}"
    echo -e "  类型: ${YELLOW}${analysis_type}${NC}"
    echo -e "  用例: ${YELLOW}$(basename $benchmark_case)${NC}"
    echo -e "  线程: ${YELLOW}${THREADS}${NC}"
    echo -e "${BLUE}======================================================================${NC}"

    # 删除旧结果
    if [ -d "$result_dir" ]; then
        echo -e "${YELLOW}删除旧结果: $result_dir${NC}"
        rm -rf "$result_dir"
    fi

    # 构建 VTune 命令（使用默认配置，VTune 2025 版本更智能）
    local vtune_cmd="vtune -collect ${analysis_type}"
    vtune_cmd="$vtune_cmd -result-dir ${result_dir}"

    # VTune 2025 会自动选择最佳配置，不需要手动指定太多 knob

    # 添加应用程序命令
    vtune_cmd="$vtune_cmd -- ${EXECUTABLE}"
    vtune_cmd="$vtune_cmd -i ${benchmark_case}"
    vtune_cmd="$vtune_cmd -o ${result_dir}/output.phys"
    vtune_cmd="$vtune_cmd -t ${THREADS}"

    # 执行分析
    echo -e "${YELLOW}执行命令:${NC}"
    echo "$vtune_cmd"
    echo ""

    # 记录开始时间
    START_TIME=$(date +%s)

    # 运行分析
    eval $vtune_cmd

    # 记录结束时间
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    echo -e "${GREEN}✓ 分析完成，耗时: ${DURATION}s${NC}"

    # 生成报告
    generate_reports "$result_dir" "$analysis_type"
}

###############################################################################
# 函数: 生成报告
###############################################################################
generate_reports() {
    local result_dir=$1
    local analysis_type=$2

    echo -e "${BLUE}[5/6] 生成报告...${NC}"

    # 生成 HTML 报告
    echo -e "生成 HTML 报告..."
    vtune -report summary -result-dir "$result_dir" -format html \
          -report-output "${result_dir}/summary.html" 2>/dev/null || true

    # 根据分析类型生成不同的报告
    case $analysis_type in
        "hotspots")
            # Top hotspots
            vtune -report hotspots -result-dir "$result_dir" -format csv \
                  -report-output "${result_dir}/hotspots.csv" 2>/dev/null || true

            # Top-down tree
            vtune -report top-down -result-dir "$result_dir" -format csv \
                  -report-output "${result_dir}/topdown.csv" 2>/dev/null || true
            ;;

        "memory-access")
            # Memory access summary
            vtune -report summary -result-dir "$result_dir" -format csv \
                  -report-output "${result_dir}/memory_summary.csv" 2>/dev/null || true

            # Memory objects
            vtune -report memory-access -result-dir "$result_dir" -format csv \
                  -report-output "${result_dir}/memory_objects.csv" 2>/dev/null || true
            ;;

        "threading")
            # Thread summary
            vtune -report summary -result-dir "$result_dir" -format csv \
                  -report-output "${result_dir}/threading_summary.csv" 2>/dev/null || true

            # Thread concurrency
            vtune -report threading -result-dir "$result_dir" -format csv \
                  -report-output "${result_dir}/thread_concurrency.csv" 2>/dev/null || true
            ;;

        "uarch-exploration")
            # Microarchitecture summary
            vtune -report summary -result-dir "$result_dir" -format csv \
                  -report-output "${result_dir}/uarch_summary.csv" 2>/dev/null || true
            ;;
    esac

    echo -e "${GREEN}✓ 报告生成完成${NC}"
    echo -e "${GREEN}  HTML 报告: ${result_dir}/summary.html${NC}"
    echo -e "${GREEN}  CSV 数据: ${result_dir}/*.csv${NC}"
}

###############################################################################
# 函数: 生成分析摘要
###############################################################################
generate_summary() {
    echo -e "${BLUE}[6/6] 生成分析摘要...${NC}"

    local summary_file="${VTUNE_RESULTS_DIR}/ANALYSIS_SUMMARY.md"

    cat > "$summary_file" << EOF
# Potter VTune 性能分析摘要

**分析时间**: $(date '+%Y-%m-%d %H:%M:%S')
**分析类型**: ${ANALYSIS_TYPE}
**线程数**: ${THREADS}
**服务器**: Ubuntu + Intel 80核心

---

## 分析结果目录

EOF

    # 列出所有结果目录
    for result_dir in "$VTUNE_RESULTS_DIR"/*; do
        if [ -d "$result_dir" ] && [ "$(basename $result_dir)" != "." ]; then
            local dir_name=$(basename "$result_dir")
            echo "### ${dir_name}" >> "$summary_file"
            echo "" >> "$summary_file"

            # 检查是否有 HTML 报告
            if [ -f "${result_dir}/summary.html" ]; then
                echo "- **HTML 报告**: [summary.html](${result_dir}/summary.html)" >> "$summary_file"
            fi

            # 列出 CSV 文件
            if ls "${result_dir}"/*.csv 1> /dev/null 2>&1; then
                echo "- **CSV 数据**:" >> "$summary_file"
                for csv in "${result_dir}"/*.csv; do
                    echo "  - $(basename $csv)" >> "$summary_file"
                done
            fi

            echo "" >> "$summary_file"
        fi
    done

    cat >> "$summary_file" << EOF

---

## 如何查看报告

### 方法 1: VTune GUI (推荐)
\`\`\`bash
vtune-gui vtune_results/<result_name>
\`\`\`

### 方法 2: 浏览器查看 HTML
\`\`\`bash
firefox vtune_results/<result_name>/summary.html
# 或
google-chrome vtune_results/<result_name>/summary.html
\`\`\`

### 方法 3: 命令行查看
\`\`\`bash
# 查看热点函数
vtune -report hotspots -result-dir vtune_results/<result_name> -format text

# 查看摘要
vtune -report summary -result-dir vtune_results/<result_name>
\`\`\`

---

## 下一步优化建议

基于 VTune 分析结果，关注以下方面：

### 1. Hotspots 分析
- 查看 Top 10 热点函数
- 识别可优化的计算密集型代码
- 检查是否有意外的高开销函数

### 2. Memory Access 分析
- **L1 缓存未命中率**: 如果 >5%，考虑数据局部性优化
- **L2 缓存未命中率**: 如果 >10%，考虑数据结构重组
- **L3 缓存未命中率**: 如果 >20%，考虑预取或分块
- **DTLB 未命中率**: 如果 >1%，考虑使用大页 (Huge Pages)

### 3. Threading 分析
- **CPU 利用率**: 应接近 80 核心 × 100% = 8000%
- **等待时间**: 如果 >10%，说明同步开销大
- **负载不均**: 查看各线程的工作量分布

### 4. Microarchitecture 分析
- **前端停顿**: 如果 >20%，优化指令缓存或分支预测
- **后端停顿**: 如果 >30%，优化内存访问或减少依赖链
- **CPI (Cycles Per Instruction)**: 理想值 <1.5，>2.0 需要优化

---

## 优化优先级判断

根据分析结果，按以下优先级进行优化：

1. **高优先级** (预期提升 >10%)
   - 热点函数占用 >5% 的函数
   - L3 缓存未命中率 >20%
   - 线程利用率 <60%

2. **中优先级** (预期提升 5-10%)
   - L2 缓存未命中率 >10%
   - 同步等待时间 >10%
   - CPI >2.0

3. **低优先级** (预期提升 <5%)
   - 分支预测失败率 >5%
   - L1 缓存未命中率 >5%

---

**生成脚本**: scripts/vtune_analysis.sh
**详细使用**: scripts/vtune_analysis.sh --help
EOF

    echo -e "${GREEN}✓ 分析摘要已生成: ${summary_file}${NC}"
}

###############################################################################
# 函数: 清理旧结果
###############################################################################
clean_results() {
    echo -e "${YELLOW}清理旧的分析结果...${NC}"
    if [ -d "$VTUNE_RESULTS_DIR" ]; then
        rm -rf "$VTUNE_RESULTS_DIR"
        echo -e "${GREEN}✓ 清理完成${NC}"
    else
        echo -e "${YELLOW}无需清理${NC}"
    fi
}

###############################################################################
# 主程序
###############################################################################
main() {
    # 解析命令行参数
    CLEAN=0
    SPECIFIC_BENCHMARK=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--type)
                ANALYSIS_TYPE="$2"
                shift 2
                ;;
            -j|--threads)
                THREADS="$2"
                shift 2
                ;;
            -b|--benchmark)
                SPECIFIC_BENCHMARK="$2"
                shift 2
                ;;
            -o|--output)
                VTUNE_RESULTS_DIR="$2"
                shift 2
                ;;
            -c|--clean)
                CLEAN=1
                shift
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

    # 如果指定清理，执行清理后退出
    if [ $CLEAN -eq 1 ]; then
        clean_results
        exit 0
    fi

    # 打印标题
    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${GREEN}       Intel VTune 性能分析 - Potter 优化项目${NC}"
    echo -e "${BLUE}======================================================================${NC}"
    echo ""

    # 执行分析流程
    check_vtune
    check_executable
    prepare_environment

    echo -e "${BLUE}[4/6] 开始性能分析...${NC}"

    # 确定要运行的分析类型
    if [ "$ANALYSIS_TYPE" == "all" ]; then
        ANALYSIS_TYPES=("hotspots" "memory-access" "threading" "uarch-exploration")
    else
        ANALYSIS_TYPES=("$ANALYSIS_TYPE")
    fi

    # 确定要运行的基准测试
    if [ -n "$SPECIFIC_BENCHMARK" ]; then
        BENCHMARKS=("${BENCHMARK_DIR}/${SPECIFIC_BENCHMARK}")
    else
        # 使用所有可用的基准测试
        BENCHMARKS=()
        for case in "${BENCHMARK_CASES[@]}"; do
            FULL_PATH="$BENCHMARK_DIR/$case"
            if [ -f "$FULL_PATH" ]; then
                BENCHMARKS+=("$FULL_PATH")
            fi
        done
    fi

    # 运行分析
    local total_runs=$((${#ANALYSIS_TYPES[@]} * ${#BENCHMARKS[@]}))
    local current_run=0

    for analysis_type in "${ANALYSIS_TYPES[@]}"; do
        for benchmark in "${BENCHMARKS[@]}"; do
            current_run=$((current_run + 1))
            echo ""
            echo -e "${BLUE}进度: ${current_run}/${total_runs}${NC}"
            run_vtune_analysis "$analysis_type" "$benchmark"
        done
    done

    # 生成摘要
    generate_summary

    echo ""
    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${GREEN}              分析完成!${NC}"
    echo -e "${BLUE}======================================================================${NC}"
    echo ""
    echo -e "结果目录: ${GREEN}${VTUNE_RESULTS_DIR}${NC}"
    echo -e "分析摘要: ${GREEN}${VTUNE_RESULTS_DIR}/ANALYSIS_SUMMARY.md${NC}"
    echo ""
    echo -e "查看报告:"
    echo -e "  ${YELLOW}cat ${VTUNE_RESULTS_DIR}/ANALYSIS_SUMMARY.md${NC}"
    echo -e "  ${YELLOW}vtune-gui ${VTUNE_RESULTS_DIR}/<result_name>${NC}"
    echo ""
}

# 运行主程序
main "$@"
