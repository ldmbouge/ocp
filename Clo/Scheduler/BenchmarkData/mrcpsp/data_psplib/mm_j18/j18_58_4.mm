************************************************************************
file with basedata            : md314_.bas
initial value random generator: 836407858
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  20
horizon                       :  132
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     18      0       18        0       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           7  11
   3        3          1           6
   4        3          3           5   6  13
   5        3          2           8  14
   6        3          3           8   9  19
   7        3          3          10  14  19
   8        3          2          16  17
   9        3          2          12  16
  10        3          2          13  16
  11        3          3          12  15  19
  12        3          2          14  17
  13        3          2          15  17
  14        3          1          18
  15        3          1          18
  16        3          1          18
  17        3          1          20
  18        3          1          20
  19        3          1          20
  20        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     8       0    8    7    5
         2     8       8    0    7    3
         3    10       0    8    7    3
  3      1     2       8    0    7    4
         2     3       0    5    4    4
         3    10       6    0    2    4
  4      1     1       0    2    7    3
         2     5       0    2    4    2
         3     8       8    0    3    2
  5      1     3       0    4    7    8
         2     7       4    0    7    7
         3     8       0    2    7    3
  6      1     2       0    9    8    9
         2     5       0    6    6    8
         3     6       0    3    5    6
  7      1     2       7    0   10    9
         2     6       0    3    8    5
         3    10       7    0    3    2
  8      1     3       0   10    2    7
         2     3       9    0    3   10
         3     8       3    0    2    5
  9      1     4       0    1    3    4
         2     5       9    0    2    4
         3    10       8    0    1    4
 10      1     1       5    0    4    6
         2     2       0    2    4    6
         3     3       0    1    4    3
 11      1     3       5    0    7    4
         2     6       0    8    6    3
         3     7       0    2    4    3
 12      1     1       0    7   10    5
         2     2       4    0    9    4
         3     4       4    0    7    4
 13      1     3       9    0    5    7
         2     5       0    6    4    7
         3     8       6    0    2    5
 14      1     3       9    0    5    8
         2     9       0    5    4    8
         3     9       0    7    4    7
 15      1     2       0    3    7    5
         2     5       8    0    7    2
         3     8       5    0    6    1
 16      1     6       8    0    5    4
         2    10       3    0    3    3
         3    10       4    0    5    1
 17      1     1       0    9    8    7
         2     2       6    0    7    7
         3     3       0    7    5    6
 18      1     1       4    0    8    9
         2     2       0    1    5    7
         3     3       2    0    4    6
 19      1     6       8    0    5    8
         2     7       5    0    4    5
         3     7       6    0    4    2
 20      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   18   12  116  115
************************************************************************
