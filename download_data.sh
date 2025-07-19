wget https://github.com/Xilinx/fpga24_routing_contest/releases/latest/download/xcvu3p.device
mkdir -p benchmarks
wget https://github.com/Xilinx/fpga24_routing_contest/releases/latest/download/benchmarks.tar.gz
wget https://github.com/Xilinx/fpga24_routing_contest/releases/latest/download/benchmarks-evaluation.tar.gz
tar -xzvf benchmarks.tar.gz -C ./benchmarks
tar -xzvf benchmarks-evaluation.tar.gz -C ./benchmarks
rm -f benchmarks.tar.gz
rm -f benchmarks-evaluation.tar.gz