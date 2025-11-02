# 快速基准测试脚本使用说明

## 快速开始

```bash
# 1. 复制脚本到项目目录
cp quick_benchmark.sh /path/to/your/project/

# 2. 运行测试
cd /path/to/your/project/
./quick_benchmark.sh
```

## 脚本功能

- ✅ 自动检测 `build/route` 或 `./route` 可执行文件
- ✅ 自动查找 `benchmarks/` 或 `../benchmarks/` 目录
- ✅ 测试3个用例，每个运行3次
- ✅ 自动计算平均时间
- ✅ 彩色输出，清晰易读
- ✅ 保存详细日志到 `benchmark_logs/`
- ✅ 生成结果文件 `benchmark_results.txt`

## 测试用例

1. **koios_dla_like_large_unrouted.phys**
2. **mlcad_d181_lefttwo3rds_unrouted.phys**
3. **ispd16_example2_unrouted.phys**

## 输出示例

```
======================================
Potter 基准测试结果
======================================
可执行文件: ./build/route
线程数: 80
运行次数: 3
时间: 2025-11-02 12:34:56
======================================

测试用例: koios_dla_like_large_unrouted.phys
  Run 1/3 ... 61.63s
  Run 2/3 ... 59.54s
  Run 3/3 ... 60.60s
  平均时间: 60.59s

测试用例: mlcad_d181_lefttwo3rds_unrouted.phys
  Run 1/3 ... 268.60s
  Run 2/3 ... 262.91s
  Run 3/3 ... 222.25s
  平均时间: 251.25s

测试用例: ispd16_example2_unrouted.phys
  Run 1/3 ... 198.79s
  Run 2/3 ... 147.99s
  Run 3/3 ... 212.74s
  平均时间: 186.51s

======================================
汇总结果
======================================
koios: 60.59s
mlcad: 251.25s
ispd: 186.51s

测试完成！
结果保存在: benchmark_results.txt
日志保存在: benchmark_logs/
```

## 结果文件

### `benchmark_results.txt`
包含所有运行的详细时间和平均值

### `benchmark_logs/`
每次运行的完整日志：
- `koios_dla_like_large_unrouted_run1.log`
- `koios_dla_like_large_unrouted_run2.log`
- `koios_dla_like_large_unrouted_run3.log`
- ... (其他用例同理)

## 配置修改

如需修改配置，编辑脚本顶部：

```bash
RUNS=3           # 每个用例运行次数
THREADS=80       # 线程数
DEVICE="xcvu3p.device"  # 设备文件
```

## 在3个项目中使用

```bash
# 项目1: 原始g++版本
cd /path/to/original_gcc_version
./quick_benchmark.sh
mv benchmark_results.txt results_gcc.txt

# 项目2: Intel+oneMKL版本
cd /path/to/intel_onemkl_version
./quick_benchmark.sh
mv benchmark_results.txt results_onemkl.txt

# 项目3: 最终优化版本
cd /path/to/final_optimized_version
./quick_benchmark.sh
mv benchmark_results.txt results_final.txt

# 对比结果
cat results_gcc.txt results_onemkl.txt results_final.txt
```

## 故障排查

**问题1: 找不到可执行文件**
```
错误: 找不到 route 可执行文件
```
解决: 确保已编译项目 (`make` 或 `./scripts/build_intel.sh`)

**问题2: 找不到benchmarks**
```
错误: 找不到 benchmarks 目录
```
解决: 确保 `benchmarks/` 目录存在且包含测试文件

**问题3: 运行失败**
```
Run 1/3 ... 失败 (执行错误)
```
解决: 查看 `benchmark_logs/` 中的日志文件，检查错误信息
