************************************************************************
file with basedata            : cn135_.bas
initial value random generator: 1607293890
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  128
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       17        9       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   7  10
   3        3          3           5   9  12
   4        3          3           9  10  16
   5        3          2          10  14
   6        3          2           8  15
   7        3          3           8  14  16
   8        3          2          11  13
   9        3          1          11
  10        3          3          11  13  15
  11        3          1          17
  12        3          1          14
  13        3          1          17
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     6       0    7   10
         2     7       3    0    5
         3     7       1    0    6
  3      1     1       2    0    6
         2     2       0    4    5
         3     7       0    3    5
  4      1     3       6    0    2
         2     4       3    0    2
         3     7       1    0    1
  5      1     4       3    0    6
         2    10       3    0    2
         3    10       0    5    2
  6      1     1       4    0    9
         2     1       0    7   10
         3     7       0    5    6
  7      1     2       0   10    8
         2     6       0    8    8
         3     7       0    5    6
  8      1     2       0    4    9
         2     2      10    0    8
         3     9       8    0    6
  9      1     2       4    0    9
         2     5       0    7    7
         3     8       4    0    5
 10      1     3       5    0    9
         2     5       0    1    5
         3     7       0    1    3
 11      1     5       0    9    8
         2     6       9    0    8
         3     6       0    5    8
 12      1     2       0    9    9
         2     4       0    7    6
         3     9       0    6    5
 13      1     5       8    0    5
         2     8       6    0    4
         3    10       0    3    1
 14      1     1       0    8    8
         2     7       7    0    7
         3     9       4    0    6
 15      1     1       4    0    4
         2     7       0    5    2
         3     9       3    0    1
 16      1     1       8    0   10
         2     3       7    0   10
         3     6       0   10   10
 17      1     2       0    6   10
         2     6       0    4    7
         3    10       0    3    3
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   23   23   86
************************************************************************
