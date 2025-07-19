.PHONY: all build run

benchmark=logicnets_jscl
benchmark_dir=./benchmarks
thread=32
timestamp := $(shell date +%y-%m-%d-%H:%M:%S)
log_folder := run/$(timestamp)
# log_folder_ := $(if $(filter $(log_folder), run), $(log_folder), run/$(log_folder))
log_folder_ := $(if $(findstring run, $(log_folder)), $(log_folder), run/$(log_folder))
all: build run evaluate check score
all_nb: run evaluate check score
all_nb1: run1 evaluate check score

# Make /usr/bin/time only print out wall-clock and user time in seconds
TIME = Wall-clock time (sec): %e
# Note that User-CPU time is for information purposes only (not used for scoring)
TIME += \nUser-CPU time (sec): %U
export TIME

create_folder:
	mkdir -p $(log_folder_)

build:
	cmake -B build -DCMAKE_BUILD_TYPE=Release . 
	cmake --build build --parallel 40

build_d:
	cmake -B build -DCMAKE_BUILD_TYPE=Debug . 
	cmake --build build --parallel 40

run: create_folder
	(/usr/bin/time ./build/route -i $(benchmark_dir)/$(benchmark)_unrouted.phys -o run/$(benchmark)_potter.phys -d xcvu3p.device -t $(thread)) 2>&1 | tee $(log_folder_)/$(benchmark)_potter.phys.log

run_r: create_folder
	(/usr/bin/time ./build/route -i $(benchmark_dir)/$(benchmark)_unrouted.phys -o run/$(benchmark)_potter.phys -d xcvu3p.device -t $(thread) -r) 2>&1 | tee $(log_folder_)/$(benchmark)_potter.phys.log

run_d:
	gdb --args ./build/route -i $(benchmark_dir)/$(benchmark)_unrouted.phys -o $(log_folder_)/$(benchmark)_rw_routed.phys -d xcvu3p.device