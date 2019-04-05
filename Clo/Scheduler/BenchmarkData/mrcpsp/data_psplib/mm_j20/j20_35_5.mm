************************************************************************
file with basedata            : md355_.bas
initial value random generator: 1280020751
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  22
horizon                       :  143
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     20      0       25       19       25
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   7  12
   3        3          3           7  11  15
   4        3          3           9  10  17
   5        3          1           6
   6        3          3           8  10  13
   7        3          3           9  18  20
   8        3          3           9  16  21
   9        3          1          19
  10        3          3          15  16  21
  11        3          3          12  16  18
  12        3          1          20
  13        3          2          14  19
  14        3          1          17
  15        3          1          19
  16        3          1          20
  17        3          1          18
  18        3          1          21
  19        3          1          22
  20        3          1          22
  21        3          1          22
  22        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     6       0    5    2    7
         2     7       5    0    2    6
         3     8       1    0    2    6
  3      1     4       7    0    9    1
         2     7       0    5    8    1
         3     9       6    0    8    1
  4      1     1       9    0    1    9
         2     3       8    0    1    9
         3     7       8    0    1    8
  5      1     1       4    0    6    6
         2     1       5    0    4    5
         3     6       0    6    4    5
  6      1     7       0    8    6    2
         2     7       6    0    6    2
         3     8       1    0    4    1
  7      1     2       0    4    6    7
         2     3       0    1    5    3
         3     3      10    0    4    4
  8      1     1       0    7    1    6
         2     2       7    0    1    5
         3     5       3    0    1    4
  9      1     3       6    0    8    9
         2     7       0    5    8    8
         3     8       0    3    7    8
 10      1     3       7    0    6    8
         2     7       2    0    5    4
         3     9       0    7    4    3
 11      1     4       0    6    7    6
         2     5       5    0    7    6
         3     7       3    0    4    2
 12      1     2       0    3    3    8
         2     3       4    0    2    5
         3     5       0    2    1    2
 13      1     2       4    0    6    2
         2     2       0    6    7    2
         3     7       0    5    2    2
 14      1     1       0    6    5    2
         2     8       0    5    5    2
         3    10       3    0    5    1
 15      1     1       8    0    9    8
         2     7       0    4    4    4
         3     7       6    0    6    5
 16      1     2       9    0    5    3
         2     3       8    0    5    3
         3    10       7    0    5    2
 17      1     1       0    4    6    7
         2     3       0    2    5    5
         3     7       9    0    4    4
 18      1     1       5    0    5    2
         2     4       4    0    4    1
         3     9       4    0    3    1
 19      1     2       6    0    5    7
         2     5       0    3    5    7
         3     7       6    0    4    6
 20      1     3       7    0    5    2
         2     4       6    0    4    1
         3     4       0    4    4    2
 21      1     6       5    0    4    5
         2     7       0    8    3    5
         3     7       4    0    3    4
 22      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   22   15   82   78
************************************************************************
