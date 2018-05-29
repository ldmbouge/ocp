************************************************************************
file with basedata            : md256_.bas
initial value random generator: 393137958
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  127
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21        6       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6  10
   3        3          3           8  11  13
   4        3          3          10  14  15
   5        3          2           7   9
   6        3          3           8  13  14
   7        3          2          13  16
   8        3          2          12  17
   9        3          1          12
  10        3          2          16  17
  11        3          3          12  14  15
  12        3          1          16
  13        3          1          15
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       7    6    6    4
         2     6       6    5    3    4
         3     9       3    2    3    3
  3      1     4       4    8    4    9
         2     9       3    7    3    4
         3    10       3    5    3    1
  4      1     3       8    3    7    5
         2     4       6    3    5    5
         3     4       8    3    7    4
  5      1     5       6    5    8    8
         2     8       4    3    8    4
         3     8       6    5    7    7
  6      1     5       8    5    7   10
         2     6       6    5    7    9
         3     7       4    5    7    9
  7      1     5       8    8    7    5
         2     6       7    8    6    5
         3     7       3    7    6    5
  8      1     1       5    5    4   10
         2    10       2    4    2    9
         3    10       2    5    1    9
  9      1     5       6   10    3    9
         2     8       5    4    2    8
         3     9       3    1    2    7
 10      1     1       6    4    5   10
         2     2       5    3    5    9
         3    10       4    3    4    9
 11      1     1       9    9    6    6
         2     6       9    7    4    5
         3     7       9    7    2    4
 12      1     5       9    6    7    5
         2     9       9    6    5    4
         3    10       8    5    2    3
 13      1     4       9    3    8   10
         2     6       9    2    7    9
         3     9       8    2    5    9
 14      1     5       6   10    7    4
         2     5       7    9    5    4
         3     8       2    7    3    4
 15      1     1      10    5    6    6
         2     5       8    5    5    5
         3     7       7    3    4    5
 16      1     1       7    6    7    5
         2     2       7    5    6    4
         3     3       6    2    6    3
 17      1     1      10    8    4    3
         2     9       5    7    1    2
         3     9       5    6    2    2
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   28   33   96  109
************************************************************************
