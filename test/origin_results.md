xaccel@xaccel:/xrepo/App/Potter$ ./build/route -i benchmarks/koios_dla_like_large_unrouted.phys -o benchmarks/koios_dla_like_large_routed.phys -t 80
./build/route -i benchmarks/mlcad_d181_lefttwo3rds_unrouted.phys -o benchmarks/mlcad_d181_lefttwo3rds_routed.phys -t 80
./build/route -i benchmarks/ispd16_example2_unrouted.phys -o benchmarks/ispd16_example2_routed.phys -t 80
[   0.002] input: benchmarks/koios_dla_like_large_unrouted.phys
[   0.002] output: benchmarks/koios_dla_like_large_routed.phys
[   0.002] device: xcvu3p.device
[   0.002] thread: 80
[   0.002] runtime first: false
[   0.002]
[   0.003] Device cache is found. Start loading.
[   3.584] Finish loading.
[   4.137] reading physical netlist...
[   4.137]
[  11.060] str_list       : 3180045
[  11.060] phys_nets      : 2485562
[  13.837] preserve net: GLOBAL_LOGIC0
[  14.428] preserve net: GLOBAL_LOGIC1
[  15.853] nets           : 508594
[  15.853] multi-src nets : 17513
[  15.853] connections    : 983642
[  15.853] indirect connections: 911608
[  15.853] direct connections  : 72034
[  15.853]
[  26.042] DeadEndNodeForPins: 592579
[  26.042] #DeadEndNode: 3205580
[  26.209] #DeadEndNode: 76516
[  26.216] #DeadEndNode: 7000
[  26.216] #DeadEndNode: 791
[  26.216] #DeadEndNode: 501
[  26.216] #DeadEndNode: 305
[  26.216] #DeadEndNode: 258
[  26.216] #DeadEndNode: 158
[  26.216] #DeadEndNode: 48
[  26.216] #DeadEndNode: 39
[  36.517] #Node: 28226432 #Node (RRG) 20790884 #Edges: 28226432 #Edges (RRG): 87644515
[  36.517] #Conns: 911608 #Nets: 911608 #Indirect: 911608 #direct: 72034
[  36.517] #preservedNum: 931601
[  43.559] Route indirect connections: 911608
[  43.889] break area (not included): 288
[  43.889] 118637/508594 nets are labeled. ratio = 0.233265
[  43.889] 455666/911608 connections are labeled, ratio = 0.499849
[  43.897] Connections bbox: [x: (-1, 108), y: (-1, 300)]
[  49.166] [kmeans] iter 184 finished.
[  49.166] [kmeans] cluster sizes:  4742  4548 10745  2234  7953  3277  8467  1806  2564  2704  1597 12826  9515  1528  5224  3198  6138  8652  1585  9466  5818  1853  3537  2453  4746  2398  3087  4605  3216  1242  8130  5339  3043  2640  2298 10392 11846  4293  2883  5827 12047 10440  3627  6197  2240  1065  3813  3506  1975  5117  8870  6201  7586  2926  6555 12559 12568  3101  8036  5351  2150  2280  2819  8717  7035  4034 15365  6974 10226  3319  3397  7313  2190  9539 10571  6998  3348  8157 15356  3959
[  49.222] Connections bbox: [x: (-1, 108), y: (-1, 300)]
[  49.809] Schedule Level: 24
[  49.809] ---------------------------------------------------------------------------------------------------------------------------
[  49.809]  Iteration        PFactor   HFactor   RoutedConnections   OverlapNodes  decreaseRatio   shareRatio     numBatches   Times
[  63.161] *        1          1.375         1              911608         481966           -inf         1.89             19   13.35
[  72.837] *        2           2.73      1.24              609468         306133           0.36         1.99             19    9.68
[  82.138] *        3           4.08      1.46              433456         177136           0.42         2.45             19    9.30
[  89.876] *        4           5.13      1.64              269942         119446           0.33         2.26             19    7.74
[  95.598]          5           5.95      1.76              129856          17956           0.85         7.23             19    5.72
[  99.169]          6           6.67      1.85               46154           6069           0.66         7.60             19    3.57
[ 101.473]          7           7.39      1.91               23234           2548           0.58         9.12             19    2.30
[ 103.002]          8           8.15      1.94               13504           1142           0.55        11.82             19    1.53
[ 104.027]          9           8.98      1.96                9132            546           0.52        16.73             19    1.02
[ 104.794]         10           9.88      1.98                6256            267           0.51        23.43             19    0.77
[ 105.313]         11          10.87      1.99                4648            131           0.51        35.48             19    0.52
[ 105.815]         12          11.96      1.99                3194             54           0.59        59.15             19    0.50
[ 106.180]         13          13.15      2.00                2488             33           0.39        75.39             19    0.37
[ 106.555]         14          14.47      2.00                2149             18           0.45       119.39             19    0.37
[ 106.859]         15          15.91      2.00                1601             14           0.22       114.36             19    0.30
[ 107.141]         16          17.51      2.00                1321             10           0.29       132.10             19    0.28
[ 107.356]         17          19.26      2.00                1108              8           0.20       138.50             19    0.22
[ 107.558]         18          21.18      2.00                 916              8           0.00       114.50             19    0.20
[ 107.743]         19          23.30      2.00                 738              4           0.50       184.50             19    0.19
[ 107.936]         20          25.63      2.00                 606              4           0.00       151.50             19    0.19
[ 108.061]         21          28.19      2.00                 435              3           0.25       145.00             19    0.12
[ 108.208]         22          31.01      2.00                 395              3           0.00       131.67             19    0.15
[ 108.278]         23          34.12      2.00                  77              2           0.33        38.50             19    0.07
[ 108.395]         24          37.53      2.00                  14              0           1.00          inf             19    0.12
[ 108.395] ---------------------------------------------------------------------------------------------------------------------------
[ 108.395] Congest ratio: 0.53 label: 1
Route indirect time: 64.84
[ 108.395] Route direct connections: 72034
[ 108.441] Direct route [Finish]. Failure: 0 / 72034
[ 108.441] Save all routing solutions [Start]
[ 109.248] FixedNetNum: 166278 / 508594
[ 109.248] Save all routing solutions [Finish]
Total route time: 65.69
[ 109.248] Dump routing solution into netlist_builder [Start]
[ 127.078] NewStrNum: 50231
[ 127.078] Dump routing solution into netlist_builder [Finish]
[ 127.080] Write to file benchmarks/koios_dla_like_large_routed.phys [Start]
[ 132.798] Write to file [Finish]
Write time: 23.61
[ 135.877] Check -1: memory_peak: 161415036 kB
[ 139.767] netlist destruct
[ 139.828] Device destruct
[   0.000] input: benchmarks/mlcad_d181_lefttwo3rds_unrouted.phys
[   0.000] output: benchmarks/mlcad_d181_lefttwo3rds_routed.phys
[   0.000] device: xcvu3p.device
[   0.000] thread: 80
[   0.000] runtime first: false
[   0.000]
[   0.000] Device cache is found. Start loading.
[   3.577] Finish loading.
[   4.127] reading physical netlist...
[   4.127]
[   8.114] str_list       : 1919510
[   8.114] phys_nets      : 1470148
[   8.399] preserve net: controlSig0
[   8.439] preserve net: controlSig1
[   9.295] preserve net: GLOBAL_LOGIC0
[   9.637] preserve net: GLOBAL_LOGIC1
[  10.642] preserve net: clk_BUFGP_net_top_wire
[  11.696] nets           : 361461
[  11.696] multi-src nets : 88553
[  11.696] connections    : 915817
[  11.696] indirect connections: 915817
[  11.696] direct connections  : 0
[  11.696]
[  21.773] DeadEndNodeForPins: 747377
[  21.773] #DeadEndNode: 2969905
[  21.935] #DeadEndNode: 23411
[  21.937] #DeadEndNode: 4669
[  21.938] #DeadEndNode: 752
[  21.938] #DeadEndNode: 586
[  21.938] #DeadEndNode: 363
[  21.938] #DeadEndNode: 204
[  21.938] #DeadEndNode: 15
[  21.938] #DeadEndNode: 9
[  21.938] #DeadEndNode: 5
[  32.099] #Node: 28226432 #Node (RRG) 21007062 #Edges: 28226432 #Edges (RRG): 89653884
[  32.099] #Conns: 915817 #Nets: 915817 #Indirect: 915817 #direct: 0
[  32.099] #preservedNum: 578025
[  40.599] Route indirect connections: 915817
[  40.902] break area (not included): 256
[  40.902] 123432/361461 nets are labeled. ratio = 0.341481
[  40.902] 436144/915817 connections are labeled, ratio = 0.476235
[  40.910] Connections bbox: [x: (-1, 75), y: (-1, 300)]
[  42.909] [kmeans] iter 73 finished.
[  42.910] [kmeans] cluster sizes:  3564  3606  3773 10916  4532 13362  4718  4484  3373  6507 11126  4029  2765  2484 10460  7186  4691  4447  2668  2422 11643  7387 12165  3609  7194  7908 11023 11962  5021  5153  4558 10574  3957  4068  3077  3057  3998  3322  2376  7072  3809 10110  6214  4094  5750  7687  3095  1655  4339  6817  2563  3300  3343  8193  4572 10662  2155  2222 11152  7487  7725  4065  3241 10950  4842  6335 10600  2677 10410  3506  4613  9603  5172  5285  2570  6544  5641 10880 10565  4993
[  42.947] Connections bbox: [x: (-1, 75), y: (-1, 300)]
[  43.386] Schedule Level: 19
[  43.386] ---------------------------------------------------------------------------------------------------------------------------
[  43.386]  Iteration        PFactor   HFactor   RoutedConnections   OverlapNodes  decreaseRatio   shareRatio     numBatches   Times
[  69.562] *        1          1.375         1              915817         519992           -inf         1.76             11   26.18
[  87.284] *        2           2.73      1.24              601375         361191           0.31         1.66             11   17.72
[ 108.413] *        3           4.08      1.46              480302         235256           0.35         2.04             11   21.13
[ 129.899] *        4           5.13      1.64              359872         174873           0.26         2.06             11   21.49
[ 150.427]          5           5.95      1.76              230316          69619           0.60         3.31             11   20.53
[ 168.265]          6           6.67      1.85              135543          40167           0.42         3.37             11   17.84
[ 184.237]          7           7.39      1.91               88465          25200           0.37         3.51             11   15.97
[ 197.823]          8           8.15      1.94               60592          16868           0.33         3.59             11   13.59
[ 210.768]          9           8.98      1.96               43361          11487           0.32         3.77             11   12.95
[ 221.672]         10           9.88      1.98               31205           7989           0.30         3.91             11   10.90
[ 232.214]         11          10.87      1.99               22360           5639           0.29         3.97             11   10.54
[ 240.701]         12          11.96      1.99               16177           4062           0.28         3.98             11    8.49
[ 250.781]         13          13.15      2.00               11600           2964           0.27         3.91             11   10.08
[ 259.025]         14          14.47      2.00                8725           2204           0.26         3.96             11    8.24
[ 274.757]         15          15.91      2.00                6491           1615           0.27         4.02             11   15.73
[ 287.247]         16          17.51      2.00                4789           1200           0.26         3.99             11   12.49
[ 299.253]         17          19.26      2.00                3445            890           0.26         3.87             11   12.01
[ 310.142]         18          21.18      2.00                2473            663           0.26         3.73             11   10.89
[ 323.259]         19          23.30      2.00                1779            500           0.25         3.56             11   13.12
[ 333.362]         20          25.63      2.00                1358            361           0.28         3.76             11   10.10
[ 341.782]         21          28.19      2.00                 896            264           0.27         3.39             11    8.42
[ 350.574]         22          31.01      2.00                 721            199           0.25         3.62             11    8.79
[ 359.572]         23          34.12      2.00                 450            148           0.26         3.04             11    9.00
[ 367.013]         24          37.53      2.00                 315            114           0.23         2.76             11    7.44
[ 374.382]         25          41.28      2.00                 292             90           0.21         3.24             11    7.37
[ 381.274]         26          45.41      2.00                 154             61           0.32         2.52             11    6.89
[ 388.282]         27          49.95      2.00                 120             46           0.25         2.61             11    7.01
[ 396.002]         28          54.94      2.00                 109             29           0.37         3.76             11    7.72
[ 399.600]         29          60.44      2.00                  68             17           0.41         4.00             11    3.60
[ 400.874]         30          66.48      2.00                  36              8           0.53         4.50             11    1.27
[ 403.626]         31          73.13      2.00                  17              9          -0.12         1.89             11    2.75
[ 407.659]         32          80.44      2.00                  13              4           0.56         3.25             11    4.03
[ 409.761]         33          88.49      2.00                  12              2           0.50         6.00             11    2.10
[ 412.001]         34          97.33      2.00                   4              1           0.50         4.00             11    2.24
[ 414.339]         35         107.07      2.00                   2              2          -1.00         1.00             11    2.34
[ 416.882]         36         117.77      2.00                   5              1           0.50         5.00             11    2.54
[ 418.695]         37         129.55      2.00                   2              0           1.00          inf             11    1.81
[ 418.695] ---------------------------------------------------------------------------------------------------------------------------
[ 418.695] Congest ratio: 0.57 label: 1
Route indirect time: 378.10
[ 418.695] Route direct connections: 0
[ 418.695] Direct route [Finish]. Failure: 0 / 0
[ 418.695] Save all routing solutions [Start]
[ 419.629] FixedNetNum: 211341 / 361461
[ 419.629] Save all routing solutions [Finish]
Total route time: 379.03
[ 419.629] Dump routing solution into netlist_builder [Start]
[ 436.521] NewStrNum: 27770
[ 436.521] Dump routing solution into netlist_builder [Finish]
[ 436.524] Write to file benchmarks/mlcad_d181_lefttwo3rds_routed.phys [Start]
[ 440.834] Write to file [Finish]
Write time: 21.24
[ 441.174] Check -1: memory_peak: 141717912 kB
[ 446.074] netlist destruct
[ 446.138] Device destruct
[   0.000] input: benchmarks/ispd16_example2_unrouted.phys
[   0.000] output: benchmarks/ispd16_example2_routed.phys
[   0.000] device: xcvu3p.device
[   0.000] thread: 80
[   0.000] runtime first: false
[   0.000]
[   0.000] Device cache is found. Start loading.
[   3.468] Finish loading.
[   4.132] reading physical netlist...
[   4.132]
[   7.760] str_list       : 1307627
[   7.760] phys_nets      : 689763
[   8.318] preserve net: controlSig0
[   8.542] preserve net: controlSig1
[   9.347] preserve net: clk_BUFGP_net_top_wire
[  10.591] preserve net: GLOBAL_LOGIC0
[  10.659] preserve net: GLOBAL_LOGIC1
[  11.957] nets           : 448794
[  11.957] multi-src nets : 200939
[  11.957] connections    : 1454556
[  11.957] indirect connections: 1454556
[  11.957] direct connections  : 0
[  11.957]
[  22.985] DeadEndNodeForPins: 1306547
[  22.985] #DeadEndNode: 2380369
[  23.149] #DeadEndNode: 20587
[  23.152] #DeadEndNode: 1343
[  23.152] #DeadEndNode: 177
[  23.152] #DeadEndNode: 23
[  32.885] #Node: 28226432 #Node (RRG) 21691815 #Edges: 28226432 #Edges (RRG): 94758940
[  32.885] #Conns: 1454556 #Nets: 1454556 #Indirect: 1454556 #direct: 0
[  32.885] #preservedNum: 453092
[  42.051] Route indirect connections: 1454556
[  42.503] break area (not included): 272
[  42.503] 118334/448794 nets are labeled. ratio = 0.263671
[  42.503] 702069/1454556 connections are labeled, ratio = 0.482669
[  42.517] Connections bbox: [x: (-1, 108), y: (-1, 300)]
[  46.163] [kmeans] iter 130 finished.
[  46.163] [kmeans] cluster sizes:  7886 10993  4600 13499  7687  8060  4709 20442  4832 15315 17204  9077  4185  3245  6473  3900  4428 17393 15897  7965  4010 10074 13223  5404  7845  4592 13861 19697  5335  5819  6037  7031 14717  9751 13897  4272 12391 13529  5676 13428 13834 14299  4885 11058  4178 18224  8929  5527  3050  2798  4170  7949  5216 17645 20121  6735 13801 14581  3619  5749 16131 15783 15622 14046  5083  6467  5059  8745 10897 10584  4188  7155  6136  2894 15132 14304  3064  9644  5621 11185
[  46.216] Connections bbox: [x: (-1, 108), y: (-1, 300)]
[  46.990] Schedule Level: 25
[  46.990] ---------------------------------------------------------------------------------------------------------------------------
[  46.990]  Iteration        PFactor   HFactor   RoutedConnections   OverlapNodes  decreaseRatio   shareRatio     numBatches   Times
[  79.301] *        1              1         1             1454556         591349           -inf         2.46             16   32.31
[ 106.202] *        2           2.00      1.00              927753         423894           0.28         2.19             16   26.90
[ 141.614] *        3           4.00      1.00              759578         270696           0.36         2.81             16   35.41
[ 166.211] *        4           8.00      1.00              556322         172110           0.36         3.23             16   24.60
[ 185.443] *        5          16.00      1.00              355198         108185           0.37         3.28             16   19.23
[ 202.437]          6          32.00      1.00              172939           7863           0.93        21.99             16   16.99
[ 214.647]          7          64.00      1.00               55251           1537           0.80        35.95             16   12.21
[ 225.827]          8         128.00      1.00               18443            368           0.76        50.12             16   11.18
[ 241.438]          9         256.00      1.00                4895            109           0.70        44.91             16   15.61
[ 249.684]         10         512.00      1.00                2243             45           0.59        49.84             16    8.25
[ 252.852]         11        1024.00      1.00                 133             29           0.36         4.59             16    3.17
[ 255.386]         12        2048.00      1.00                  62             19           0.34         3.26             16    2.53
[ 257.756]         13        4096.00      1.00                  42             10           0.47         4.20             16    2.37
[ 259.470]         14        8192.00      1.00                  27              6           0.40         4.50             16    1.71
[ 259.813]         15       16384.00      1.00                  10              2           0.67         5.00             16    0.34
[ 260.308]         16       32768.00      1.00                   6              2           0.00         3.00             16    0.50
[ 260.424]         17       65536.00      1.00                   2              1           0.50         2.00             16    0.12
[ 260.510]         18      131072.00      1.00                   1              1           0.00         1.00             16    0.09
[ 260.616]         19      262144.00      1.00                   6              1           0.00         6.00             16    0.11
[ 260.713]         20      524288.00      1.00                   5              0           1.00          inf             16    0.10
[ 260.714] ---------------------------------------------------------------------------------------------------------------------------
[ 260.714] Congest ratio: 0.41 label: 0
Route indirect time: 218.66
[ 260.714] Route direct connections: 0
[ 260.714] Direct route [Finish]. Failure: 0 / 0
[ 260.714] Save all routing solutions [Start]
[ 261.741] FixedNetNum: 285987 / 448794
[ 261.741] Save all routing solutions [Finish]
Total route time: 219.69
[ 261.741] Dump routing solution into netlist_builder [Start]
[ 278.177] NewStrNum: 35201
[ 278.177] Dump routing solution into netlist_builder [Finish]
[ 278.182] Write to file benchmarks/ispd16_example2_routed.phys [Start]
[ 282.654] Write to file [Finish]
Write time: 20.96
[ 282.998] Check -1: memory_peak: 129432424 kB
[ 287.362] netlist destruct
[ 287.421] Device destruct
