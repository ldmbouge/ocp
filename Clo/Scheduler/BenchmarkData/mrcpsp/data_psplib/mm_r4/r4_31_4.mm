************************************************************************
file with basedata            : cr431_.bas
initial value random generator: 130774318
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  117
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       17       10       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   8  12
   3        3          2           5  11
   4        3          2           7  11
   5        3          3           6   8  12
   6        3          2           9  14
   7        3          1          14
   8        3          3          10  16  17
   9        3          3          10  16  17
  10        3          1          15
  11        3          2          12  13
  12        3          1          15
  13        3          2          14  15
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     1       2    8   10    3   10    0
         2     2       1    7    9    3    0    8
         3     4       1    4    7    3    7    0
  3      1     2       2    2    3    2    0    3
         2     5       1    2    3    2    3    0
         3     9       1    1    2    2    0    3
  4      1     1       8    3    3    5    5    0
         2     6       5    3    3    5    0    2
         3    10       3    2    2    5    2    0
  5      1     1       4    4    6    5    0    9
         2     1       4    4    7    5    3    0
         3     6       4    3    3    3    0    9
  6      1     1       6    4    8    8    0    5
         2     1       6    3    9    8    2    0
         3     6       3    2    6    8    0    4
  7      1     2       7    5    9    8    3    0
         2     4       7    5    8    6    3    0
         3     8       5    2    8    4    0    4
  8      1     3       9    5    5    5    0    6
         2     5       7    4    3    5    0    4
         3     9       6    3    3    5    8    0
  9      1     1       2    6    5    5    0    7
         2     3       2    4    3    5    0    4
         3     5       2    3    3    5    0    2
 10      1     6       5    7    5    8    0    6
         2     6       6    9    4    8    2    0
         3     8       4    3    3    5    0    6
 11      1     3       4    9    6    5    0    5
         2     6       4    7    4    4    0    4
         3     8       4    6    3    4    0    4
 12      1     4      10    4    6    3    0    6
         2    10      10    4    5    3    4    0
         3    10      10    4    4    2    0    6
 13      1     5       7    4    3    9   10    0
         2     6       5    3    3    8    0    4
         3     8       5    2    3    6    9    0
 14      1     6       7    7    5    2    0    5
         2     7       7    6    4    2    0    3
         3    10       4    4    4    1    0    3
 15      1     2       3    7    7    7    0    8
         2     5       3    6    5    6    2    0
         3     7       1    6    5    5    2    0
 16      1     1       4    7    3    6    0    8
         2     4       3    4    3    4    5    0
         3     4       3    4    3    3    0    8
 17      1     1      10    7    6    4    0    4
         2     5       9    4    5    3    0    3
         3     5       9    3    6    3    7    0
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   22   17   19   17   64   90
************************************************************************
