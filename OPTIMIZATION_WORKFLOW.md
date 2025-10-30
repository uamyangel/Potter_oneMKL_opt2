# Potter 性能优化工作流程

## 概述

本文档描述基于 **Intel VTune 数据驱动** 的 Potter 性能优化工作流程。

**核心原则**: 先用 VTune 分析找出真实瓶颈，再针对性优化，而不是盲目应用各种优化技术。

---

## 📊 阶段一：性能分析（数据收集）

### 1. 编译带调试符号的版本

```bash
# 使用 RelWithDebInfo 构建（O3 优化 + 调试符号）
cd /Users/xiaofs/opengpt/ai-manual/oxygen/Potter_oneMKL_opt2

# 清理并重新编译
rm -rf build
cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_CXX_COMPILER=icpx \
      -DCMAKE_C_COMPILER=icx

cmake --build build -j 80
```

**说明**: RelWithDebInfo 保持 -O3 优化，同时包含调试符号供 VTune 使用。

### 2. 运行 VTune 性能分析

#### 选项 A: CPU 热点分析（推荐首次使用）

```bash
# 运行热点分析
./scripts/vtune_analysis.sh -t hotspots

# 查看结果摘要
cat vtune_results/ANALYSIS_SUMMARY.md

# 在浏览器中查看详细报告
firefox vtune_results/hotspots_*/summary.html &
```

**分析重点**:
- Top 10 热点函数及其 CPU 时间占比
- 识别占用 >5% CPU 时间的函数
- 确定优化优先级

#### 选项 B: 全面分析（耗时较长）

```bash
# 运行所有类型的分析（hotspots, memory-access, threading, uarch-exploration）
./scripts/vtune_analysis.sh -t all
```

**建议**: 首次分析用 `hotspots`，根据结果决定是否需要其他类型分析。

### 3. 解读 VTune 报告

参考详细指南：[docs/VTUNE_GUIDE.md](docs/VTUNE_GUIDE.md)

**关键问题**:
1. 哪些函数是热点？（CPU 时间占比）
2. 是否有明显的内存访问问题？（缓存未命中率）
3. 并行效率如何？（CPU 利用率、等待时间）
4. 微架构层面有何瓶颈？（CPI、停顿比例）

---

## 🎯 阶段二：基于数据的优化决策

### 决策树

```
VTune 热点分析结果
    │
    ├─ 单个函数占用 >20% CPU 时间
    │   └─→ 【优先级 1】优化该函数的算法和数据结构
    │
    ├─ 多个函数占用 5-15% CPU 时间
    │   └─→ 【优先级 2】逐一优化这些函数
    │
    ├─ L3 缓存未命中率 >20%
    │   └─→ 【优先级 1】内存访问优化
    │       - 添加软件预取
    │       - 数据结构重组
    │       - NUMA 优化
    │
    ├─ CPU 利用率 <60%（80核服务器）
    │   └─→ 【优先级 1】并行度优化
    │       - 减少同步开销
    │       - 改善负载均衡
    │       - 调整批次粒度
    │
    └─ CPI >2.0 或后端停顿 >40%
        └─→ 【优先级 2】微架构优化
            - 优化内存访问模式
            - 减少指令依赖链
```

### 优化方向及预期提升

| 瓶颈类型 | 优化措施 | 预期提升 | 难度 |
|---------|---------|---------|------|
| **热点函数算法** | 算法优化、更高效数据结构 | 10-30% | 中-高 |
| **内存访问** | 预取、数据布局、NUMA 绑定 | 20-30% | 中 |
| **并行效率低** | 减少同步、动态负载均衡 | 15-25% | 中 |
| **批次粒度不当** | 调整批次数量（256→16/32） | 5-10% | 低 |
| **线程创建开销** | 使用线程池 | 3-5% | 低 |

---

## 🔧 阶段三：实施针对性优化

### 示例优化 1: 减少批次数量（低风险快速优化）

**VTune 数据支持**: Threading 分析显示同步开销 >10%

```cpp
// src/route/aStarRoute.h
// 修改前
int numBatches = 256;

// 修改后
int numBatches = 16;  // 减少同步次数
```

**预期提升**: 5-10%

### 示例优化 2: 添加软件预取（基于 Memory Access 分析）

**VTune 数据支持**: Memory Access 分析显示 L3 缓存未命中率 >25%

```cpp
// src/route/aStarRoute.cpp - routeOneConnection()
for (RouteNode* childRNode : rnode->getChildren()) {
    // 添加预取下一个节点的数据
    __builtin_prefetch(&nodeInfosForThreads[tid][childRNode->getId()], 0, 3);

    // 原有代码...
    double nodeCost = getNodeCost(childRNode, connection, ...);
}
```

**预期提升**: 5-10%

### 示例优化 3: NUMA 绑定（基于 uarch-exploration）

**VTune 数据支持**: Memory bandwidth 接近饱和，跨 NUMA 访问多

```cpp
// 在线程启动时绑定到本地 NUMA 节点
#include <numa.h>

void bindThreadToNuma(int tid) {
    int numa_node = tid / cores_per_numa_node;
    numa_run_on_node(numa_node);

    // 分配内存到本地 NUMA 节点
    nodeInfosForThreads[tid] = (NodeInfo*)numa_alloc_onnode(size, numa_node);
}
```

**预期提升**: 10-15%

---

## ✅ 阶段四：验证优化效果

### 1. 重新编译

```bash
cmake --build build -j 80
```

### 2. 运行基准测试

```bash
# 使用相同的测试用例和线程数
cd build
time ./route -i ../benchmarks/fpga24_mcnc_processed/koios_dla_like_large.phys \
             -o output.phys \
             -t 80
```

### 3. 重新运行 VTune 分析

```bash
# 清理旧结果
mv vtune_results vtune_results_before_opt

# 运行新的分析
./scripts/vtune_analysis.sh -t hotspots
mv vtune_results vtune_results_after_opt
```

### 4. 对比分析

```bash
# 对比热点函数
echo "=== 优化前 Top 5 热点 ==="
grep -A 6 "CPU 热点函数" vtune_results_before_opt/ANALYSIS_SUMMARY.md | head -15

echo "=== 优化后 Top 5 热点 ==="
grep -A 6 "CPU 热点函数" vtune_results_after_opt/ANALYSIS_SUMMARY.md | head -15

# 计算性能提升
# (假设优化前 100s，优化后 80s)
# 提升 = (100 - 80) / 100 = 20%
```

---

## 🔄 迭代优化

```
1. VTune 分析 → 识别瓶颈
        ↓
2. 设计优化方案
        ↓
3. 实施优化
        ↓
4. 验证效果（VTune + 基准测试）
        ↓
5. 如果未达目标 → 返回步骤 1
   如果达到目标 → 完成
```

**建议**:
- 每次优化一个或几个相关的问题
- 每次优化后都运行 VTune 验证
- 保存每次的 VTune 结果用于对比
- 记录优化过程和效果

---

## 📂 项目文件说明

### 核心脚本

| 文件 | 用途 |
|------|------|
| `scripts/vtune_analysis.sh` | VTune 性能分析主脚本 |
| `scripts/analyze_vtune_results.py` | VTune 结果解析和报告生成 |
| `docs/VTUNE_GUIDE.md` | VTune 使用详细指南 |
| `CMakeLists.txt` | 支持 RelWithDebInfo 构建类型 |

### VTune 结果目录

```
vtune_results/
├── hotspots_koios_dla_like_large/      # 热点分析结果
│   ├── summary.html                     # HTML 报告
│   ├── hotspots.csv                     # 热点函数 CSV
│   └── ANALYSIS_REPORT.md               # 自动生成的分析报告
├── memory-access_koios_dla_like_large/ # 内存访问分析
├── threading_koios_dla_like_large/     # 线程分析
└── ANALYSIS_SUMMARY.md                 # 所有分析的总结
```

---

## 🎓 学习资源

- **VTune 详细指南**: [docs/VTUNE_GUIDE.md](docs/VTUNE_GUIDE.md)
- **Intel VTune 官方文档**: https://www.intel.com/content/www/us/en/docs/vtune-profiler/user-guide/
- **性能优化方法论**: [Intel 优化参考手册](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)

---

## 💡 关键要点

1. **数据驱动**: 永远先用 VTune 分析，再优化
2. **优先级明确**: 优化占用 CPU 时间 >5% 的函数
3. **保守实施**: 避免大规模重构，优先低风险优化
4. **持续验证**: 每次优化后都用 VTune 验证效果
5. **记录过程**: 保存每次的分析结果和优化记录

---

## 🚀 快速开始

```bash
# 1. 编译
cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_CXX_COMPILER=icpx
cmake --build build -j 80

# 2. 运行 VTune 热点分析
./scripts/vtune_analysis.sh -t hotspots

# 3. 查看结果
cat vtune_results/ANALYSIS_SUMMARY.md
firefox vtune_results/hotspots_*/summary.html

# 4. 根据数据决定优化方向
# （参考本文档的决策树和优化示例）

# 5. 实施优化后重新测试
cmake --build build -j 80
./scripts/vtune_analysis.sh -t hotspots
```

---

**文档版本**: 1.0
**最后更新**: 2025-10-30
**优化目标**: 相比原版提升 50% 性能（当前已提升 ~4%）
