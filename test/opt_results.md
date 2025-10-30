xaccel@xaccel:/xrepo/App/Potter_oneMKL_opt1$ ./build/route -i benchmarks/koios_dla_like_large_unrouted.phys -o benchmarks/koios_dla_like_large_routed.phys -t 80
[   0.000] input: benchmarks/koios_dla_like_large_unrouted.phys
[   0.000] output: benchmarks/koios_dla_like_large_routed.phys
[   0.000] device: xcvu3p.device
[   0.000] thread: 80
[   0.001] runtime first: false
[   0.001]
[   0.001] Device cache is found. Start loading.
[   3.417] Finish loading.
[   4.174] reading physical netlist...
[   4.174]
[  10.947] str_list       : 3180045
[  10.947] phys_nets      : 2485562
[  13.998] preserve net: GLOBAL_LOGIC0
[  14.602] preserve net: GLOBAL_LOGIC1
[  15.976] nets           : 508594
[  15.976] multi-src nets : 17513
[  15.976] connections    : 983642
[  15.976] indirect connections: 911608
[  15.976] direct connections  : 72034
[  15.976]
[  25.685] DeadEndNodeForPins: 592579
[  25.685] #DeadEndNode: 3205580
[  25.863] #DeadEndNode: 76516
[  25.870] #DeadEndNode: 7000
[  25.871] #DeadEndNode: 791
[  25.871] #DeadEndNode: 501
[  25.871] #DeadEndNode: 305
[  25.871] #DeadEndNode: 258
[  25.871] #DeadEndNode: 158
[  25.871] #DeadEndNode: 48
[  25.871] #DeadEndNode: 39
[  34.838] #Node: 28226432 #Node (RRG) 20790884 #Edges: 28226432 #Edges (RRG): 87644515
[  34.838] #Conns: 911608 #Nets: 911608 #Indirect: 911608 #direct: 72034
[  34.838] #preservedNum: 931601
[  43.490] Route indirect connections: 911608
[  43.776] break area (not included): 288
[  43.776] 118637/508594 nets are labeled. ratio = 0.233265
[  43.776] 455666/911608 connections are labeled, ratio = 0.499849
[  43.786] Connections bbox: [x: (-1, 108), y: (-1, 300)]
[  48.276] [kmeans] iter 184 finished.
[  48.276] [kmeans] cluster sizes:  4742  4548 10745  2234  7953  3277  8467  1806  2564  2704  1597 12826  9515  1528  5224  3198  6138  8652  1585  9466  5818  1853  3537  2453  4746  2398  3087  4605  3216  1242  8130  5339  3043  2640  2298 10392 11846  4293  2883  5827 12047 10440  3627  6197  2240  1065  3813  3506  1975  5117  8870  6201  7586  2926  6555 12559 12568  3101  8036  5351  2150  2280  2819  8717  7035  4034 15365  6974 10226  3319  3397  7313  2190  9539 10571  6998  3348  8157 15356  3959
[  48.323] Connections bbox: [x: (-1, 108), y: (-1, 300)]
[  48.912] Schedule Level: 24
[  48.912] ---------------------------------------------------------------------------------------------------------------------------
[  48.912]  Iteration        PFactor   HFactor   RoutedConnections   OverlapNodes  decreaseRatio   shareRatio     numBatches   Times
[  60.160] *        1          1.375         1              911608         481978           -inf         1.89             19   11.25
[  69.575] *        2           2.73      1.24              609471         306173           0.36         1.99             19    9.41
[  79.502] *        3           4.08      1.46              433521         177101           0.42         2.45             19    9.93
[  87.407] *        4           5.13      1.64              269764         119303           0.33         2.26             19    7.90
[  92.876]          5           5.95      1.76              130015          17994           0.85         7.23             19    5.47
[  96.113]          6           6.67      1.85               46639           6100           0.66         7.65             19    3.24
[  98.116]          7           7.39      1.91               22934           2571           0.58         8.92             19    2.00
[  99.920]          8           8.15      1.94               13900           1168           0.55        11.90             19    1.80
[ 101.038]          9           8.98      1.96                9084            555           0.52        16.37             19    1.12
[ 101.977]         10           9.88      1.98                6423            308           0.45        20.85             19    0.94
[ 102.835]         11          10.87      1.99                5346            131           0.57        40.81             19    0.86
[ 103.521]         12          11.96      1.99                3447             65           0.50        53.03             19    0.69
[ 104.028]         13          13.15      2.00                2596             42           0.35        61.81             19    0.51
[ 104.327]         14          14.47      2.00                2062             20           0.52       103.10             19    0.30
[ 104.555]         15          15.91      2.00                1443             10           0.50       144.30             19    0.23
[ 104.780]         16          17.51      2.00                1316              9           0.10       146.22             19    0.23
[ 104.974]         17          19.26      2.00                1112              8           0.11       139.00             19    0.19
[ 105.136]         18          21.18      2.00                 925              8           0.00       115.62             19    0.16
[ 105.271]         19          23.30      2.00                 755              4           0.50       188.75             19    0.13
[ 105.397]         20          25.63      2.00                 627              4           0.00       156.75             19    0.13
[ 105.496]         21          28.19      2.00                 451              3           0.25       150.33             19    0.10
[ 105.600]         22          31.01      2.00                 398              3           0.00       132.67             19    0.10
[ 105.663]         23          34.12      2.00                  78              2           0.33        39.00             19    0.06
[ 105.717]         24          37.53      2.00                  14              0           1.00          inf             19    0.05
[ 105.717] ---------------------------------------------------------------------------------------------------------------------------
[ 105.717] Congest ratio: 0.53 label: 1
Route indirect time: 62.23
[ 105.717] Route direct connections: 72034
[ 105.775] Direct route [Finish]. Failure: 0 / 72034
[ 105.775] Save all routing solutions [Start]
[ 106.678] FixedNetNum: 164226 / 508594
[ 106.678] Save all routing solutions [Finish]
Total route time: 63.19
[ 106.678] Dump routing solution into netlist_builder [Start]
[ 125.434] NewStrNum: 50232
[ 125.434] Dump routing solution into netlist_builder [Finish]
[ 125.437] Write to file benchmarks/koios_dla_like_large_routed.phys [Start]
[ 131.749] Write to file [Finish]
Write time: 25.13
[ 134.142] Check -1: memory_peak: 161658896 kB
[ 138.060] netlist destruct
[ 138.127] Device destruct
xaccel@xaccel:/xrepo/App/Potter_oneMKL_opt1$ ./build/route -i benchmarks/mlcad_d181_lefttwo3rds_unrouted.phys -o benchmarks/mlcad_d181_lefttwo3rds_routed.phys -t 80
./build/route -i benchmarks/ispd16_example2_unrouted.phys -o benchmarks/ispd16_example2_routed.phys -t 80
[   0.000] input: benchmarks/mlcad_d181_lefttwo3rds_unrouted.phys
[   0.000] output: benchmarks/mlcad_d181_lefttwo3rds_routed.phys
[   0.000] device: xcvu3p.device
[   0.000] thread: 80
[   0.000] runtime first: false
[   0.000]
[   0.000] Device cache is found. Start loading.
[   3.164] Finish loading.
[   3.791] reading physical netlist...
[   3.791]
[   7.778] str_list       : 1919510
[   7.778] phys_nets      : 1470148
[   8.077] preserve net: controlSig0
[   8.121] preserve net: controlSig1
[   9.005] preserve net: GLOBAL_LOGIC0
[   9.318] preserve net: GLOBAL_LOGIC1
[  10.204] preserve net: clk_BUFGP_net_top_wire
[  11.142] nets           : 361461
[  11.142] multi-src nets : 88553
[  11.142] connections    : 915817
[  11.142] indirect connections: 915817
[  11.142] direct connections  : 0
[  11.143]
[  21.850] DeadEndNodeForPins: 747377
[  21.850] #DeadEndNode: 2969905
[  22.045] #DeadEndNode: 23411
[  22.048] #DeadEndNode: 4669
[  22.048] #DeadEndNode: 752
[  22.048] #DeadEndNode: 586
[  22.048] #DeadEndNode: 363
[  22.049] #DeadEndNode: 204
[  22.049] #DeadEndNode: 15
[  22.049] #DeadEndNode: 9
[  22.049] #DeadEndNode: 5
[  32.953] #Node: 28226432 #Node (RRG) 21007062 #Edges: 28226432 #Edges (RRG): 89653884
[  32.953] #Conns: 915817 #Nets: 915817 #Indirect: 915817 #direct: 0
[  32.953] #preservedNum: 578025
[  39.965] Route indirect connections: 915817
[  40.227] break area (not included): 256
[  40.227] 123432/361461 nets are labeled. ratio = 0.341481
[  40.227] 436144/915817 connections are labeled, ratio = 0.476235
[  40.238] Connections bbox: [x: (-1, 75), y: (-1, 300)]
[  42.057] [kmeans] iter 73 finished.
[  42.057] [kmeans] cluster sizes:  3564  3606  3773 10916  4532 13362  4718  4484  3373  6507 11126  4029  2765  2484 10460  7186  4691  4447  2668  2422 11643  7387 12165  3609  7194  7908 11023 11962  5021  5153  4558 10574  3957  4068  3077  3057  3998  3322  2376  7072  3809 10110  6214  4094  5750  7687  3095  1655  4339  6817  2563  3300  3343  8193  4572 10662  2155  2222 11152  7487  7725  4065  3241 10950  4842  6335 10600  2677 10410  3506  4613  9603  5172  5285  2570  6544  5641 10880 10565  4993
[  42.086] Connections bbox: [x: (-1, 75), y: (-1, 300)]
[  42.485] Schedule Level: 19
[  42.485] ---------------------------------------------------------------------------------------------------------------------------
[  42.485]  Iteration        PFactor   HFactor   RoutedConnections   OverlapNodes  decreaseRatio   shareRatio     numBatches   Times
[  61.453] *        1          1.375         1              915817         520024           -inf         1.76             11   18.97
[  78.636] *        2           2.73      1.24              601394         361128           0.31         1.67             11   17.18
[  98.817] *        3           4.08      1.46              480156         235208           0.35         2.04             11   20.18
[ 118.789] *        4           5.13      1.64              360034         175218           0.26         2.05             11   19.97
[ 138.105]          5           5.95      1.76              231593          69698           0.60         3.32             11   19.32
[ 156.974]          6           6.67      1.85              135763          40215           0.42         3.38             11   18.87
[ 173.422]          7           7.39      1.91               88535          25536           0.37         3.47             11   16.45
[ 186.919]          8           8.15      1.94               61335          17196           0.33         3.57             11   13.50
[ 199.329]          9           8.98      1.96               43756          11825           0.31         3.70             11   12.41
[ 210.020]         10           9.88      1.98               31944           8426           0.29         3.79             11   10.69
[ 219.025]         11          10.87      1.99               23247           5747           0.32         4.05             11    9.01
[ 227.688]         12          11.96      1.99               16255           4127           0.28         3.94             11    8.66
[ 236.304]         13          13.15      2.00               12051           3108           0.25         3.88             11    8.62
[ 243.391]         14          14.47      2.00                9044           2308           0.26         3.92             11    7.09
[ 255.074]         15          15.91      2.00                6736           1732           0.25         3.89             11   11.68
[ 267.902]         16          17.51      2.00                5048           1284           0.26         3.93             11   12.83
[ 278.302]         17          19.26      2.00                3550            935           0.27         3.80             11   10.40
[ 288.935]         18          21.18      2.00                2611            734           0.21         3.56             11   10.63
[ 297.712]         19          23.30      2.00                2097            591           0.19         3.55             11    8.78
[ 306.646]         20          25.63      2.00                1506            445           0.25         3.38             11    8.93
[ 316.975]         21          28.19      2.00                1137            342           0.23         3.32             11   10.33
[ 324.214]         22          31.01      2.00                 870            253           0.26         3.44             11    7.24
[ 332.798]         23          34.12      2.00                 551            168           0.34         3.28             11    8.58
[ 342.331]         24          37.53      2.00                 368            144           0.14         2.56             11    9.53
[ 350.319]         25          41.28      2.00                 266            107           0.26         2.49             11    7.99
[ 357.440]         26          45.41      2.00                 221             75           0.30         2.95             11    7.12
[ 362.824]         27          49.95      2.00                 158             63           0.16         2.51             11    5.38
[ 366.809]         28          54.94      2.00                 107             47           0.25         2.28             11    3.98
[ 373.031]         29          60.44      2.00                 107             37           0.21         2.89             11    6.22
[ 379.267]         30          66.48      2.00                  69             22           0.41         3.14             11    6.24
[ 384.683]         31          73.13      2.00                  39             14           0.36         2.79             11    5.42
[ 385.543]         32          80.44      2.00                  23              9           0.36         2.56             11    0.86
[ 385.715]         33          88.49      2.00                  15              7           0.22         2.14             11    0.17
[ 385.986]         34          97.33      2.00                  14              7           0.00         2.00             11    0.27
[ 386.158]         35         107.07      2.00                  16              4           0.43         4.00             11    0.17
[ 387.108]         36         117.77      2.00                   5              1           0.75         5.00             11    0.95
[ 387.505]         37         129.55      2.00                   6              2          -1.00         3.00             11    0.40
[ 387.907]         38         142.51      2.00                   8              2           0.00         4.00             11    0.40
[ 388.208]         39         156.76      2.00                   2              1           0.50         2.00             11    0.30
[ 388.450]         40         172.43      2.00                   5              0           1.00          inf             11    0.24
[ 388.450] ---------------------------------------------------------------------------------------------------------------------------
[ 388.450] Congest ratio: 0.57 label: 1
Route indirect time: 348.48
[ 388.450] Route direct connections: 0
[ 388.450] Direct route [Finish]. Failure: 0 / 0
[ 388.450] Save all routing solutions [Start]
[ 389.391] FixedNetNum: 213138 / 361461
[ 389.391] Save all routing solutions [Finish]
Total route time: 349.43
[ 389.391] Dump routing solution into netlist_builder [Start]
[ 405.615] NewStrNum: 27777
[ 405.615] Dump routing solution into netlist_builder [Finish]
[ 405.618] Write to file benchmarks/mlcad_d181_lefttwo3rds_routed.phys [Start]
[ 409.981] Write to file [Finish]
Write time: 20.63
[ 410.301] Check -1: memory_peak: 141437520 kB
[ 415.261] netlist destruct
[ 415.313] Device destruct
[   0.000] input: benchmarks/ispd16_example2_unrouted.phys
[   0.000] output: benchmarks/ispd16_example2_routed.phys
[   0.000] device: xcvu3p.device
[   0.000] thread: 80
[   0.000] runtime first: false
[   0.000]
[   0.001] Device cache is found. Start loading.
[   3.322] Finish loading.
[   3.996] reading physical netlist...
[   3.996]
[   7.637] str_list       : 1307627
[   7.637] phys_nets      : 689763
[   8.320] preserve net: controlSig0
[   8.485] preserve net: controlSig1
[   9.265] preserve net: clk_BUFGP_net_top_wire
[  10.317] preserve net: GLOBAL_LOGIC0
[  10.377] preserve net: GLOBAL_LOGIC1
[  11.490] nets           : 448794
[  11.490] multi-src nets : 200939
[  11.490] connections    : 1454556
[  11.490] indirect connections: 1454556
[  11.490] direct connections  : 0
[  11.490]
[  20.583] DeadEndNodeForPins: 1306547
[  20.583] #DeadEndNode: 2380369
[  20.738] #DeadEndNode: 20587
[  20.740] #DeadEndNode: 1343
[  20.740] #DeadEndNode: 177
[  20.740] #DeadEndNode: 23
[  30.065] #Node: 28226432 #Node (RRG) 21691815 #Edges: 28226432 #Edges (RRG): 94758940
[  30.065] #Conns: 1454556 #Nets: 1454556 #Indirect: 1454556 #direct: 0
[  30.065] #preservedNum: 453092
[  36.785] Route indirect connections: 1454556
[  37.212] break area (not included): 272
[  37.213] 118334/448794 nets are labeled. ratio = 0.263671
[  37.213] 702069/1454556 connections are labeled, ratio = 0.482669
[  37.229] Connections bbox: [x: (-1, 108), y: (-1, 300)]
[  40.799] [kmeans] iter 130 finished.
[  40.799] [kmeans] cluster sizes:  7886 10993  4600 13499  7687  8060  4709 20442  4832 15315 17204  9077  4185  3245  6473  3900  4428 17393 15897  7965  4010 10074 13223  5404  7845  4592 13861 19697  5335  5819  6037  7031 14717  9751 13897  4272 12391 13529  5676 13428 13834 14299  4885 11058  4178 18224  8929  5527  3050  2798  4170  7949  5216 17645 20121  6735 13801 14581  3619  5749 16131 15783 15622 14046  5083  6467  5059  8745 10897 10584  4188  7155  6136  2894 15132 14304  3064  9644  5621 11185
[  40.841] Connections bbox: [x: (-1, 108), y: (-1, 300)]
[  41.535] Schedule Level: 25
[  41.535] ---------------------------------------------------------------------------------------------------------------------------
[  41.535]  Iteration        PFactor   HFactor   RoutedConnections   OverlapNodes  decreaseRatio   shareRatio     numBatches   Times
[  72.457] *        1              1         1             1454556         591346           -inf         2.46             16   30.92
[ 100.117] *        2           2.00      1.00              927792         423906           0.28         2.19             16   27.66
[ 129.328] *        3           4.00      1.00              759524         270687           0.36         2.81             16   29.21
[ 158.626] *        4           8.00      1.00              556366         172060           0.36         3.23             16   29.30
[ 181.476] *        5          16.00      1.00              355313         108050           0.37         3.29             16   22.85
[ 198.715]          6          32.00      1.00              172850           7890           0.93        21.91             16   17.24
[ 212.071]          7          64.00      1.00               54747           1523           0.81        35.95             16   13.36
[ 226.364]          8         128.00      1.00               16939            368           0.76        46.03             16   14.29
[ 243.020]          9         256.00      1.00                4673            119           0.68        39.27             16   16.66
[ 248.596]         10         512.00      1.00                2388             50           0.58        47.76             16    5.58
[ 250.021]         11        1024.00      1.00                 144             23           0.54         6.26             16    1.42
[ 251.278]         12        2048.00      1.00                  47             10           0.57         4.70             16    1.26
[ 253.012]         13        4096.00      1.00                  22              4           0.60         5.50             16    1.73
[ 253.106]         14        8192.00      1.00                  23              0           1.00          inf             16    0.09
[ 253.106] ---------------------------------------------------------------------------------------------------------------------------
[ 253.106] Congest ratio: 0.41 label: 0
Route indirect time: 216.32
[ 253.106] Route direct connections: 0
[ 253.106] Direct route [Finish]. Failure: 0 / 0
[ 253.106] Save all routing solutions [Start]
[ 254.093] FixedNetNum: 267145 / 448794
[ 254.093] Save all routing solutions [Finish]
Total route time: 217.31
[ 254.093] Dump routing solution into netlist_builder [Start]
[ 272.854] NewStrNum: 35201
[ 272.854] Dump routing solution into netlist_builder [Finish]
[ 272.859] Write to file benchmarks/ispd16_example2_routed.phys [Start]
[ 277.403] Write to file [Finish]
Write time: 23.38
[ 277.744] Check -1: memory_peak: 128339708 kB
[ 282.239] netlist destruct
[ 282.310] Device destruct