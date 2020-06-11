************************************************************************
file with basedata            : cn345_.bas
initial value random generator: 596968196
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  128
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       22        1       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          13  14  15
   3        3          3           5   8  14
   4        3          3           8  11  16
   5        3          3           6   9  10
   6        3          3           7  11  13
   7        3          1          15
   8        3          1          10
   9        3          2          11  13
  10        3          1          12
  11        3          2          12  17
  12        3          1          15
  13        3          2          16  17
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     4       9    4    7    8    3
         2    10       4    4    4    8    2
         3    10       4    2    4    8    3
  3      1     5       4    6    4    7    6
         2     7       3    4    2    7    4
         3     7       2    2    3    7    3
  4      1     1       5    7    5    7    7
         2     4       3    7    3    6    4
         3     9       2    6    1    6    4
  5      1     1       8    7    8    8    6
         2     2       6    7    8    8    4
         3    10       3    3    8    8    3
  6      1     2       4    9    7    5    8
         2     8       3    4    2    5    7
         3     8       2    2    4    4    7
  7      1     3      10    6    8    5    3
         2     3      10    7    7    9    3
         3     6       8    4    3    1    2
  8      1     2       8    2    7    9    2
         2     2       7    2    8    6    2
         3     8       2    1    7    2    2
  9      1     3       9   10    8    3    4
         2     6       6   10    7    3    4
         3     9       4   10    6    2    4
 10      1     2       9    9    8    9    9
         2     9       8    7    7    6    9
         3     9       9    8    5    6    9
 11      1     3      10    3    6    8   10
         2     5       9    3    4    4    6
         3     8       9    3    2    1    4
 12      1     6      10    9    8    3    6
         2     6      10    9    7    3    8
         3     9       9    8    5    2    4
 13      1     6       7    9    9    6    6
         2     8       5    7    6    6    5
         3    10       2    5    4    5    4
 14      1     1       5    8    4    8    9
         2     1       4    7    6    8    9
         3     5       1    6    4    7    7
 15      1     4       4    8    9    8    3
         2     4       4    8   10    7    3
         3     6       4    7    9    6    2
 16      1     4      10    6    6    6    2
         2     6       7    6    6    5    2
         3     8       7    5    3    3    1
 17      1     4       6    5    6    6    8
         2     6       5    4    6    1    8
         3     6       6    5    5    1    8
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   14   15   92   90   80
************************************************************************
