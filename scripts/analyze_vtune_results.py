#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Intel VTune 结果分析工具
用途: 自动解析 VTune 报告，提取关键性能指标，生成优化建议
作者: Claude Code
日期: 2025-10-30
"""

import os
import sys
import csv
import json
import argparse
import subprocess
from pathlib import Path
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict


@dataclass
class HotspotFunction:
    """热点函数数据"""
    function_name: str
    cpu_time: float  # 秒
    cpu_time_percent: float  # 百分比
    module: str


@dataclass
class MemoryMetrics:
    """内存访问指标"""
    l1_misses: Optional[float] = None
    l2_misses: Optional[float] = None
    l3_misses: Optional[float] = None
    dtlb_misses: Optional[float] = None
    memory_bandwidth_gb_s: Optional[float] = None


@dataclass
class ThreadingMetrics:
    """线程指标"""
    cpu_utilization: Optional[float] = None  # 百分比
    thread_count: Optional[int] = None
    wait_time_percent: Optional[float] = None
    load_imbalance: Optional[float] = None


@dataclass
class MicroarchMetrics:
    """微架构指标"""
    cpi: Optional[float] = None  # Cycles Per Instruction
    frontend_stall_percent: Optional[float] = None
    backend_stall_percent: Optional[float] = None
    branch_mispred_percent: Optional[float] = None


@dataclass
class PerformanceAnalysis:
    """完整的性能分析报告"""
    analysis_type: str
    benchmark: str
    hotspots: List[HotspotFunction]
    memory: Optional[MemoryMetrics] = None
    threading: Optional[ThreadingMetrics] = None
    microarch: Optional[MicroarchMetrics] = None
    recommendations: List[str] = None


class VTuneAnalyzer:
    """VTune 结果分析器"""

    def __init__(self, result_dir: Path):
        self.result_dir = result_dir
        self.analysis = None

    def parse_hotspots(self, csv_file: Path) -> List[HotspotFunction]:
        """解析 hotspots CSV 文件"""
        hotspots = []

        if not csv_file.exists():
            return hotspots

        try:
            with open(csv_file, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    # CSV 列名可能不同，尝试多种可能
                    function_name = row.get('Function', row.get('Function Stack', 'Unknown'))
                    cpu_time_str = row.get('CPU Time', row.get('CPU Time:Self', '0'))
                    cpu_time_percent_str = row.get('CPU Time:Self %', row.get('% of Total', '0'))
                    module = row.get('Module', row.get('Module Name', 'Unknown'))

                    # 解析时间（可能是 "1.234s" 格式）
                    cpu_time = self._parse_time(cpu_time_str)
                    cpu_time_percent = self._parse_percent(cpu_time_percent_str)

                    if cpu_time > 0:
                        hotspots.append(HotspotFunction(
                            function_name=function_name,
                            cpu_time=cpu_time,
                            cpu_time_percent=cpu_time_percent,
                            module=module
                        ))
        except Exception as e:
            print(f"警告: 解析 hotspots CSV 失败: {e}", file=sys.stderr)

        # 按 CPU 时间排序
        hotspots.sort(key=lambda x: x.cpu_time, reverse=True)
        return hotspots[:20]  # 返回 top 20

    def parse_summary(self) -> Dict[str, Any]:
        """解析 summary 报告，提取关键指标"""
        summary_csv = self.result_dir / "summary.csv"
        summary_data = {}

        if summary_csv.exists():
            try:
                with open(summary_csv, 'r', encoding='utf-8') as f:
                    reader = csv.reader(f)
                    for row in reader:
                        if len(row) >= 2:
                            key = row[0].strip()
                            value = row[1].strip()
                            summary_data[key] = value
            except Exception as e:
                print(f"警告: 解析 summary CSV 失败: {e}", file=sys.stderr)

        return summary_data

    def analyze(self) -> PerformanceAnalysis:
        """执行完整分析"""
        # 确定分析类型
        dir_name = self.result_dir.name
        if 'hotspots' in dir_name:
            analysis_type = 'hotspots'
        elif 'memory' in dir_name:
            analysis_type = 'memory-access'
        elif 'threading' in dir_name:
            analysis_type = 'threading'
        elif 'uarch' in dir_name:
            analysis_type = 'uarch-exploration'
        else:
            analysis_type = 'unknown'

        # 提取基准测试名称
        benchmark = self._extract_benchmark_name(dir_name)

        # 解析 hotspots
        hotspots_csv = self.result_dir / "hotspots.csv"
        hotspots = self.parse_hotspots(hotspots_csv)

        # 如果没有 hotspots.csv，尝试从 summary 中提取
        if not hotspots:
            hotspots = self._extract_hotspots_from_summary()

        # 创建分析对象
        analysis = PerformanceAnalysis(
            analysis_type=analysis_type,
            benchmark=benchmark,
            hotspots=hotspots
        )

        # 根据类型解析特定指标
        if analysis_type == 'memory-access':
            analysis.memory = self._parse_memory_metrics()
        elif analysis_type == 'threading':
            analysis.threading = self._parse_threading_metrics()
        elif analysis_type == 'uarch-exploration':
            analysis.microarch = self._parse_microarch_metrics()

        # 生成优化建议
        analysis.recommendations = self._generate_recommendations(analysis)

        self.analysis = analysis
        return analysis

    def _extract_benchmark_name(self, dir_name: str) -> str:
        """从目录名提取基准测试名称"""
        # 例如: "hotspots_koios_dla_like_large" -> "koios_dla_like_large"
        parts = dir_name.split('_', 1)
        if len(parts) > 1:
            return parts[1]
        return "unknown"

    def _extract_hotspots_from_summary(self) -> List[HotspotFunction]:
        """从 summary 中提取热点函数（备用方案）"""
        # 尝试使用 vtune 命令行工具
        hotspots = []
        try:
            result = subprocess.run(
                ['vtune', '-report', 'hotspots', '-result-dir', str(self.result_dir),
                 '-format', 'csv', '-csv-delimiter', 'comma'],
                capture_output=True,
                text=True,
                timeout=30
            )
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                reader = csv.DictReader(lines)
                for row in reader:
                    function_name = row.get('Function', 'Unknown')
                    cpu_time_str = row.get('CPU Time', '0')
                    cpu_time_percent_str = row.get('% of Total', '0')
                    module = row.get('Module', 'Unknown')

                    cpu_time = self._parse_time(cpu_time_str)
                    cpu_time_percent = self._parse_percent(cpu_time_percent_str)

                    if cpu_time > 0:
                        hotspots.append(HotspotFunction(
                            function_name=function_name,
                            cpu_time=cpu_time,
                            cpu_time_percent=cpu_time_percent,
                            module=module
                        ))
        except Exception as e:
            print(f"警告: 无法从 vtune 命令提取热点: {e}", file=sys.stderr)

        hotspots.sort(key=lambda x: x.cpu_time, reverse=True)
        return hotspots[:20]

    def _parse_memory_metrics(self) -> MemoryMetrics:
        """解析内存访问指标"""
        # 这里需要根据实际的 VTune 报告格式来解析
        # 由于格式可能因版本而异，这里提供一个框架
        return MemoryMetrics()

    def _parse_threading_metrics(self) -> ThreadingMetrics:
        """解析线程指标"""
        return ThreadingMetrics()

    def _parse_microarch_metrics(self) -> MicroarchMetrics:
        """解析微架构指标"""
        return MicroarchMetrics()

    def _generate_recommendations(self, analysis: PerformanceAnalysis) -> List[str]:
        """基于分析结果生成优化建议"""
        recommendations = []

        # 分析热点函数
        if analysis.hotspots:
            top_hotspot = analysis.hotspots[0]
            if top_hotspot.cpu_time_percent > 10:
                recommendations.append(
                    f"🔥 关键热点: {top_hotspot.function_name} 占用 {top_hotspot.cpu_time_percent:.1f}% CPU 时间，"
                    f"这是主要优化目标"
                )

            # 检查是否有多个高占用函数
            high_cpu_funcs = [h for h in analysis.hotspots if h.cpu_time_percent > 5]
            if len(high_cpu_funcs) > 3:
                recommendations.append(
                    f"📊 发现 {len(high_cpu_funcs)} 个高 CPU 占用函数 (>5%)，建议逐一优化"
                )

        # 内存相关建议
        if analysis.memory:
            if analysis.memory.l3_misses and analysis.memory.l3_misses > 20:
                recommendations.append(
                    f"💾 L3 缓存未命中率 {analysis.memory.l3_misses:.1f}% 偏高，"
                    f"建议: 1) 添加软件预取 2) 优化数据布局 3) 减少工作集大小"
                )

            if analysis.memory.dtlb_misses and analysis.memory.dtlb_misses > 1:
                recommendations.append(
                    f"📄 DTLB 未命中率 {analysis.memory.dtlb_misses:.1f}% 偏高，"
                    f"建议启用 Huge Pages (2MB 页)"
                )

        # 线程相关建议
        if analysis.threading:
            if analysis.threading.cpu_utilization and analysis.threading.cpu_utilization < 60:
                recommendations.append(
                    f"⚠️ CPU 利用率仅 {analysis.threading.cpu_utilization:.1f}%，"
                    f"线程未充分利用，建议检查负载均衡和同步开销"
                )

            if analysis.threading.wait_time_percent and analysis.threading.wait_time_percent > 10:
                recommendations.append(
                    f"⏳ 线程等待时间占 {analysis.threading.wait_time_percent:.1f}%，"
                    f"建议: 1) 减少同步点 2) 使用无锁数据结构 3) 调整批次粒度"
                )

        # 微架构相关建议
        if analysis.microarch:
            if analysis.microarch.cpi and analysis.microarch.cpi > 2.0:
                recommendations.append(
                    f"🔧 CPI (Cycles Per Instruction) = {analysis.microarch.cpi:.2f} 偏高，"
                    f"表明存在性能瓶颈，建议深入分析内存访问和指令依赖"
                )

            if analysis.microarch.backend_stall_percent and analysis.microarch.backend_stall_percent > 30:
                recommendations.append(
                    f"🚧 后端停顿占 {analysis.microarch.backend_stall_percent:.1f}%，"
                    f"主要原因是内存访问慢或执行单元饱和"
                )

        if not recommendations:
            recommendations.append("✅ 未发现明显的性能瓶颈，可以尝试更细粒度的分析")

        return recommendations

    def _parse_time(self, time_str: str) -> float:
        """解析时间字符串，例如 "1.234s" -> 1.234"""
        try:
            # 移除单位
            time_str = time_str.replace('s', '').replace('ms', 'e-3').replace('us', 'e-6')
            return float(time_str)
        except:
            return 0.0

    def _parse_percent(self, percent_str: str) -> float:
        """解析百分比字符串，例如 "12.34%" -> 12.34"""
        try:
            return float(percent_str.replace('%', '').strip())
        except:
            return 0.0

    def generate_markdown_report(self, output_file: Path):
        """生成 Markdown 格式的分析报告"""
        if not self.analysis:
            self.analyze()

        analysis = self.analysis

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(f"# VTune 性能分析报告\n\n")
            f.write(f"**分析类型**: {analysis.analysis_type}\n")
            f.write(f"**基准测试**: {analysis.benchmark}\n")
            f.write(f"**生成时间**: {self._get_timestamp()}\n\n")

            f.write("---\n\n")

            # 热点函数
            if analysis.hotspots:
                f.write("## 🔥 CPU 热点函数 (Top 10)\n\n")
                f.write("| 排名 | 函数名 | CPU 时间 | 占比 | 模块 |\n")
                f.write("|------|--------|----------|------|------|\n")
                for i, hotspot in enumerate(analysis.hotspots[:10], 1):
                    f.write(f"| {i} | `{hotspot.function_name}` | "
                           f"{hotspot.cpu_time:.3f}s | "
                           f"**{hotspot.cpu_time_percent:.1f}%** | "
                           f"{hotspot.module} |\n")
                f.write("\n")

            # 内存指标
            if analysis.memory:
                f.write("## 💾 内存访问指标\n\n")
                if analysis.memory.l1_misses is not None:
                    f.write(f"- **L1 缓存未命中率**: {analysis.memory.l1_misses:.2f}%\n")
                if analysis.memory.l2_misses is not None:
                    f.write(f"- **L2 缓存未命中率**: {analysis.memory.l2_misses:.2f}%\n")
                if analysis.memory.l3_misses is not None:
                    f.write(f"- **L3 缓存未命中率**: {analysis.memory.l3_misses:.2f}%\n")
                if analysis.memory.dtlb_misses is not None:
                    f.write(f"- **DTLB 未命中率**: {analysis.memory.dtlb_misses:.2f}%\n")
                if analysis.memory.memory_bandwidth_gb_s is not None:
                    f.write(f"- **内存带宽**: {analysis.memory.memory_bandwidth_gb_s:.2f} GB/s\n")
                f.write("\n")

            # 线程指标
            if analysis.threading:
                f.write("## 🧵 线程并行指标\n\n")
                if analysis.threading.cpu_utilization is not None:
                    f.write(f"- **CPU 利用率**: {analysis.threading.cpu_utilization:.1f}%\n")
                if analysis.threading.thread_count is not None:
                    f.write(f"- **线程数**: {analysis.threading.thread_count}\n")
                if analysis.threading.wait_time_percent is not None:
                    f.write(f"- **等待时间占比**: {analysis.threading.wait_time_percent:.1f}%\n")
                if analysis.threading.load_imbalance is not None:
                    f.write(f"- **负载不均**: {analysis.threading.load_imbalance:.1f}%\n")
                f.write("\n")

            # 微架构指标
            if analysis.microarch:
                f.write("## ⚙️ 微架构指标\n\n")
                if analysis.microarch.cpi is not None:
                    f.write(f"- **CPI (Cycles Per Instruction)**: {analysis.microarch.cpi:.2f}\n")
                if analysis.microarch.frontend_stall_percent is not None:
                    f.write(f"- **前端停顿**: {analysis.microarch.frontend_stall_percent:.1f}%\n")
                if analysis.microarch.backend_stall_percent is not None:
                    f.write(f"- **后端停顿**: {analysis.microarch.backend_stall_percent:.1f}%\n")
                if analysis.microarch.branch_mispred_percent is not None:
                    f.write(f"- **分支预测失败**: {analysis.microarch.branch_mispred_percent:.1f}%\n")
                f.write("\n")

            # 优化建议
            if analysis.recommendations:
                f.write("## 💡 优化建议\n\n")
                for i, rec in enumerate(analysis.recommendations, 1):
                    f.write(f"{i}. {rec}\n\n")

            f.write("---\n\n")
            f.write(f"**分析工具**: Intel VTune Profiler\n")
            f.write(f"**结果目录**: `{self.result_dir}`\n")

        print(f"✓ 分析报告已生成: {output_file}")

    def _get_timestamp(self) -> str:
        """获取当前时间戳"""
        from datetime import datetime
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def main():
    parser = argparse.ArgumentParser(
        description="Intel VTune 结果分析工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
    # 分析单个结果目录
    python3 analyze_vtune_results.py -d vtune_results/hotspots_koios_dla_like_large

    # 分析所有结果目录
    python3 analyze_vtune_results.py -a vtune_results/

    # 生成 JSON 格式输出
    python3 analyze_vtune_results.py -d vtune_results/hotspots_test -f json
        """
    )

    parser.add_argument('-d', '--dir', type=str,
                       help='VTune 结果目录')
    parser.add_argument('-a', '--all', type=str,
                       help='分析指定目录下的所有 VTune 结果')
    parser.add_argument('-f', '--format', choices=['markdown', 'json'], default='markdown',
                       help='输出格式 (默认: markdown)')
    parser.add_argument('-o', '--output', type=str,
                       help='输出文件路径')

    args = parser.parse_args()

    if not args.dir and not args.all:
        parser.print_help()
        sys.exit(1)

    # 分析单个目录
    if args.dir:
        result_dir = Path(args.dir)
        if not result_dir.exists():
            print(f"错误: 目录不存在: {result_dir}", file=sys.stderr)
            sys.exit(1)

        analyzer = VTuneAnalyzer(result_dir)
        analysis = analyzer.analyze()

        # 输出
        if args.format == 'json':
            output_file = Path(args.output) if args.output else result_dir / "analysis.json"
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(asdict(analysis), f, indent=2, ensure_ascii=False)
            print(f"✓ JSON 报告已生成: {output_file}")
        else:
            output_file = Path(args.output) if args.output else result_dir / "ANALYSIS_REPORT.md"
            analyzer.generate_markdown_report(output_file)

    # 分析所有子目录
    elif args.all:
        base_dir = Path(args.all)
        if not base_dir.exists():
            print(f"错误: 目录不存在: {base_dir}", file=sys.stderr)
            sys.exit(1)

        # 查找所有 VTune 结果目录（包含 .amplxeproj 或其他标识文件）
        result_dirs = [d for d in base_dir.iterdir() if d.is_dir() and not d.name.startswith('.')]

        if not result_dirs:
            print(f"警告: 未找到 VTune 结果目录", file=sys.stderr)
            sys.exit(1)

        print(f"找到 {len(result_dirs)} 个结果目录")

        for result_dir in result_dirs:
            print(f"\n分析: {result_dir.name}")
            try:
                analyzer = VTuneAnalyzer(result_dir)
                analysis = analyzer.analyze()

                if args.format == 'json':
                    output_file = result_dir / "analysis.json"
                    with open(output_file, 'w', encoding='utf-8') as f:
                        json.dump(asdict(analysis), f, indent=2, ensure_ascii=False)
                else:
                    output_file = result_dir / "ANALYSIS_REPORT.md"
                    analyzer.generate_markdown_report(output_file)

            except Exception as e:
                print(f"  错误: {e}", file=sys.stderr)
                continue


if __name__ == "__main__":
    main()
