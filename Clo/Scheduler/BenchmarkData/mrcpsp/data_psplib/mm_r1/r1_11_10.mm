************************************************************************
file with basedata            : cr111_.bas
initial value random generator: 552653464
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  133
RESOURCES
  - renewable                 :  1   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23       11       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   9  10
   3        3          3          14  15  16
   4        3          2           5   9
   5        3          2           6  12
   6        3          1          14
   7        3          2           8  14
   8        3          2          11  13
   9        3          2          12  13
  10        3          2          11  13
  11        3          2          12  15
  12        3          2          16  17
  13        3          3          15  16  17
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     4       0    8    0
         2     8       4    5    0
         3     8       0    0    4
  3      1     3       6    8    0
         2     7       2    0    7
         3    10       0    0    7
  4      1     3       0    8    0
         2     8       0    6    0
         3    10       0    0    2
  5      1     2      10    0    9
         2     5       0    7    0
         3    10      10    0    6
  6      1     2       4    5    0
         2     3       2    0    7
         3     9       0    3    0
  7      1     6       5    9    0
         2     7       0    9    0
         3    10       0    0    3
  8      1     1      10    4    0
         2     9       9    2    0
         3    10       7    0    5
  9      1     1       5    0    2
         2     1       0   10    0
         3     3       0    4    0
 10      1     3       3    3    0
         2     9       0    3    0
         3    10       0    0    8
 11      1     2       0    0    4
         2     9       4    0    2
         3    10       3    1    0
 12      1     1       8    0    5
         2     3       0    6    0
         3     8       6    0    5
 13      1     5       0    9    0
         2     6       7    4    0
         3     8       6    3    0
 14      1     1       0    8    0
         2     1       6    0    2
         3     3       0    0    1
 15      1     2       8    0    9
         2     5       6    0    8
         3     5       0    2    0
 16      1     1       4    4    0
         2     1       0    0    5
         3    10       0    6    0
 17      1     7       3    0    7
         2     8       0    7    0
         3     9       0    0    5
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  N 1  N 2
   14   52   40
************************************************************************
