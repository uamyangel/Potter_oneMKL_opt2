# Potter: An Open-Source High-Concurrency and High-Performance Parallel Router for UltraScale FPGAs

## Brief intro
Potter is a <ins>p</ins>arallel <ins>o</ins>verlap-<ins>t</ins>olerant FPGA rou<ins>ter</ins> for Xilinx UltraScale FPGAs. It allows signal nets with overlapping bounding boxes to be routed in parallel to improve the runtime performance. Potter supports two modes with different purposes, including
1. The runtime-first *Potter-R*: It is a non-deterministic router, striving for maximum acceleration. It can achieve 12.34x speedup compared to the sequential router [RWRoute](https://dl.acm.org/doi/10.1145/3491236).
2. The stability-first *Potter-S*: It is a deterministic routing, guaranteeing the stability of the routing solutions. It can achieve 4.27x speedup to [RWRoute](https://dl.acm.org/doi/10.1145/3491236). 

More details can be found in the following papers:

Wenhao Lin, Xinshi Zang, Zewen Li and Evangeline F. Y. Young, [An Open-Source High-Concurrency and High-Performance Parallel Router for UltraScale FPGAs.](https://ieeexplore.ieee.org/document/11075842) In IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems, doi: 10.1109/TCAD.2025.3587534.

Xinshi Zang, Wenhao Lin, Jinwei Liu, and Evangeline F. Y. Young. 2025. [Potter: A Parallel Overlap-Tolerant Router for UltraScale FPGAs.](https://dl.acm.org/doi/abs/10.1145/3676536.3676783) In Proceedings of the 43rd IEEE/ACM International Conference on Computer-Aided Design (ICCAD '24). Association for Computing Machinery, New York, NY, USA, Article 174, 1–8.

Xinshi Zang, Wenhao Lin, Shiju Lin, Jinwei Liu, and Evangeline F.Y. Young. 2024. [An Open-Source Fast Parallel Routing Approach for Commercial FPGAs.](https://dl.acm.org/doi/abs/10.1145/3649476.3658714) In Proceedings of the Great Lakes Symposium on VLSI 2024 (GLSVLSI '24). Association for Computing Machinery, New York, NY, USA, 164–169.

## How to Build
**Step 1**: Ensure the following dependencies are installed:
+ libz (1.2.13 or later version)
+ gcc (9.4.0 or later version)
+ Boost (component "serialization" required, 1.74.0 or later version)

**Step 2**: Clone the Potter repository:
```
git clone https://github.com/diriLin/Potter.git
```

**Step 3**: Build the executable binary:
```sh
make build
```
The executable binary is in the path `./build/route` by default.

## How to Run
Step 1: Data preparation. The following script will automatically download the target device file and benchmarks in the [FPGA 2024 Runtime-First Routing Contest](https://github.com/Xilinx/fpga24_routing_contest):
```sh
./download_data.sh
```

Step 2: Run the router with the following command:
```
./build/route -i <input>.phys -o <output>.phys [-d <device_file> [-t <num_thread> [-r]]]
```
+ `<input>.phys`            The path to input (unrouted) physical netlist (`*_unrouted.phys` in the FPGA \'24 benchmarks)
+ `<output>.phys`           The path to output (routed) physical netlist
+ `<device_file>`           The path to device file (default: xcvu3p.device)
+ `<num_thread>`            The number of threads (default: 32)
+ `-r` or `--runtime_first` Enable runtime-first mode (without this option, the router will run in stability-first mode by default)

Note: In the first run, the target device file is parsed and the neccessary data is dumped into the folder `./dump/`. In the following runs, the parsed data will be loaded directly to reduce loading time.

## Compute the critical path wirelength of a routed design
```python
python wirelength_analyzer/wa.py <output>.phys
```
+ `<output>.phys`: the path to the output physical netlist.
+ `wirelength_analyzer`: the wirelength analyzer provided by the organizers of FPGA \'24 routing contest.
    + Visit the [scoring criteria page of FPGA \'24 routing contest](https://xilinx.github.io/fpga24_routing_contest/score.html) for more information

## Transform the routed design into Vivado DCP format
The open-source Java framework for Xilinx FPGA, [RapidWright](https://github.com/Xilinx/RapidWright), provides the tools for transformation between [**FPGAIF**](https://fpga-interchange-schema.readthedocs.io/) format (the open-source file format used in FPGA \'24 contest) and **DCP** format (the file format in Vivado workflow). Please follow the below steps to transform your routing result into DCP format with RapidWright:
+ Install [RapidWright](https://github.com/Xilinx/RapidWright). Please refer to [the installation guide](https://github.com/Xilinx/RapidWright/blob/master/README.md).
+ Use the class [PhysicalNetlistToDcp](https://github.com/Xilinx/RapidWright/blob/master/src/com/xilinx/rapidwright/interchange/PhysicalNetlistToDcp.java) to execute transformation:
    + Usage: `<RAPIDWRIGHT_HOME>/bin/rapidwright PhysicalNetlistToDcp <input>.netlist <input>.phys <input>.xdc <output>.dcp`
    + `<input>.netlist`: the input logical netlist file (provided in the FPGA \'24 benchmarks)
    + `<input>.phys`: the input physical netlist file
    + `<input>.xdc`: the input constraints (can provide an empty contraint file)
    + `<output>.dcp`: the path to output DCP file

After transforming the routed design into Vivado DCP format, you can visualize the routing result and use `report_route_status` command in Vivado to check the legality of the routed design.

## Citation
If you find Potter useful in your research, please cite the following papers:
```
@article{lin2025open,
  title={An Open-Source High-Concurrency and High-Performance Parallel Router for UltraScale FPGAs},
  author={Lin, Wenhao and Zang, Xinshi and Li, Zewen and Young, Evangeline FY},
  journal={IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems},
  year={2025},
  publisher={IEEE}
}

@inproceedings{zang2024potter,
  title={Potter: A Parallel Overlap-Tolerant Router for UltraScale FPGAs},
  author={Zang, Xinshi and Lin, Wenhao and Liu, Jinwei and Young, Evangeline FY},
  booktitle={Proceedings of the 43rd IEEE/ACM International Conference on Computer-Aided Design},
  pages={1--8},
  year={2024}
}

@inproceedings{zang2024open,
  title={An open-source fast parallel routing approach for commercial FPGAs},
  author={Zang, Xinshi and Lin, Wenhao and Lin, Shiju and Liu, Jinwei and Young, Evangeline FY},
  booktitle={Proceedings of the Great Lakes Symposium on VLSI 2024},
  pages={164--169},
  year={2024}
}
```
## Contact
Wenhao Lin (whlin23@cse.cuhk.edu.hk)

Xinshi Zang (zang-xs@foxmail.com)

## License
Potter is an open source project licensed under a BSD 3-Clause License that can be found in the [LICENSE](./LICENSE) file.
