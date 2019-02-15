************************************************************************
file with basedata            : cr441_.bas
initial value random generator: 1904323375
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  135
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       17        5       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6  14
   3        3          2           8  13
   4        3          3           7   9  14
   5        3          3           7   9  17
   6        3          3           8   9  17
   7        3          2           8  15
   8        3          1          16
   9        3          2          10  11
  10        3          2          12  16
  11        3          2          12  16
  12        3          1          13
  13        3          1          15
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     2       0    5    0    0    5    9
         2     2      10    0    0    0    4    8
         3     8       0    5    0    9    4    5
  3      1     3       5    0    0    0    9    4
         2     5       0    9    1    0    9    4
         3     7       0    3    0    5    8    4
  4      1     3       3    2    0    0    3    5
         2    10       0    0    3    0    3    4
         3    10       0    0    0    6    3    4
  5      1     4       0    0    6    7    9   10
         2     5      10    0    5    0    9    9
         3     9      10    0    0    0    7    9
  6      1     2       8    0    7    0    9    7
         2     8       0    5    0    7    8    6
         3     9       8    0    0    0    8    2
  7      1     3       0    0    7    6    8    7
         2     3       9    0    0    5    7    7
         3     4       9    6    0    0    7    2
  8      1     4       0    0    7    8    7    7
         2     7       0    4    7    0    4    4
         3    10       7    0    7    7    4    4
  9      1     3      10    0    0    0    9    2
         2     5       9    0    0    0    9    1
         3     8       9    0    0    3    8    1
 10      1     2       8    9    9    0    4    9
         2     4       0    6    7    7    4    9
         3     5       8    0    5    3    2    8
 11      1     2       0    8    0    9    2   10
         2     3       0    8    0    0    2    9
         3    10       0    7    0    3    1    7
 12      1     4       2    0    6    9    8    4
         2     9       2    0    4    9    5    3
         3    10       1    0    2    0    4    2
 13      1     1       3    7    0    8    9    9
         2     1       0    8    3    5    9    9
         3    10       0    4    0    0    8    9
 14      1     2       7    5    7    3    5    7
         2     9       3    4    0    3    2    5
         3     9       0    0    7    0    5    7
 15      1     1       8    5    6    2    3    5
         2     7       5    0    2    0    3    2
         3     7       7    0    0    0    3    2
 16      1     3       0    4    7    5    9    8
         2     7       8    2    0    0    7    8
         3    10       7    0    6    5    6    7
 17      1     2       7    0    0    0    3    9
         2     7       0    0    0    9    2    9
         3     9       0   10    9    0    1    8
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   13   13   12    5   89   96
************************************************************************
