************************************************************************
file with basedata            : cr134_.bas
initial value random generator: 1789899270
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  128
RESOURCES
  - renewable                 :  1   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23        9       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          11  14  17
   3        3          2           6  11
   4        3          3           5   8   9
   5        3          2          11  13
   6        3          2           7   8
   7        3          2           9  14
   8        3          2          14  16
   9        3          3          10  12  15
  10        3          2          13  17
  11        3          2          15  16
  12        3          2          13  17
  13        3          1          16
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     2       5    4    7
         2     2       8    3    7
         3    10       0    3    6
  3      1     2       9    6    9
         2     4       0    4    7
         3     5       0    4    5
  4      1     4       0    4    6
         2     7      10    3    5
         3     9       0    3    4
  5      1     2       3    2    4
         2     6       2    2    3
         3    10       2    2    2
  6      1     4       5    4    5
         2     7       3    3    3
         3     7       0    2    4
  7      1     2       4    6    8
         2     2       0    7    8
         3     3       0    6    7
  8      1     5       9    3    3
         2     8       0    3    3
         3     9       9    2    3
  9      1     7       9    8    8
         2     8       7    6    5
         3     9       0    4    2
 10      1     1       6    7    7
         2     1       7    5    8
         3    10       0    1    7
 11      1     1       0    8    4
         2     4      10    5    3
         3     9      10    3    3
 12      1     4       0    2    8
         2     5       0    1    7
         3     7       3    1    5
 13      1     3       0    8    7
         2     5       0    4    4
         3     8       0    4    2
 14      1     1       5    7    9
         2     5       0    3    9
         3     7       0    3    8
 15      1     1       8    7    8
         2     6       8    6    5
         3     7       0    5    3
 16      1     1       8    9    3
         2     5       0    4    3
         3     9       0    1    3
 17      1     2       6    6    7
         2     4       0    5    4
         3     9       0    5    1
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  N 1  N 2
   15   60   74
************************************************************************
