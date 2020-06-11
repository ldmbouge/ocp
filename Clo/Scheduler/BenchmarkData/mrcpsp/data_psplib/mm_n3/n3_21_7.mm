************************************************************************
file with basedata            : cn321_.bas
initial value random generator: 1699769248
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  134
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       24        4       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   7
   3        3          2           5   9
   4        3          3           5   9  17
   5        3          3          10  12  14
   6        3          3           8   9  17
   7        3          1           8
   8        3          3          10  12  14
   9        3          2          11  14
  10        3          1          16
  11        3          1          15
  12        3          1          13
  13        3          2          15  16
  14        3          2          15  16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     3       5    2    9    0    0
         2     9       4    2    0    4    0
         3    10       4    1    9    0    2
  3      1     2       9    5    0    9    0
         2     4       9    4    8    0    0
         3     5       9    3    5    0    3
  4      1     2       4    2    0    4    5
         2     3       4    2    0    4    0
         3     9       3    1    3    0    0
  5      1     9       6   10    9    4    9
         2     9       7   10    8    7    0
         3     9       8    9    0    5    0
  6      1     1       8   10    0    0    9
         2     2       8    8    8    0    0
         3    10       5    7    0    0    7
  7      1     5       7    7    0    0    8
         2     8       5    6    3    0    0
         3    10       2    4    2    8    0
  8      1     7       6    5    8    0    4
         2     8       4    4    0    3    0
         3     8       5    3    5    3    0
  9      1     8      10    4    7    7    5
         2     8       9    4    7    8    0
         3     9       4    3    0    7    0
 10      1     2       7    7    4    9    0
         2     7       4    6    3    0    0
         3     9       3    6    0    7    0
 11      1     2      10    5    0    4    0
         2     6       9    5    7    0    0
         3     9       9    2    4    0    4
 12      1     2       5    8    0    4    7
         2     7       5    6    4    0    0
         3     9       2    3    0    3    0
 13      1     3       5    8   10    0    5
         2     4       4    8    0    0    2
         3    10       3    5    7    0    0
 14      1     2       6   10    8    8    0
         2     3       6    7    8    0    6
         3     9       4    3    0    0    5
 15      1     4       7    9    6    1    9
         2     5       4    7    0    1    0
         3     5       7    8    1    0    0
 16      1     4      10    4    0    0    8
         2     5       9    4    7    4    0
         3     8       9    3    6    0    0
 17      1     2      10    6    8    4    9
         2     5       9    4    7    3    6
         3     5       9    3    0    0    7
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   16   14   82   61   71
************************************************************************
