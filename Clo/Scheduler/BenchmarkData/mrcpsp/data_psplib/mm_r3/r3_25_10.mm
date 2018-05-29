************************************************************************
file with basedata            : cr325_.bas
initial value random generator: 376625196
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  140
RESOURCES
  - renewable                 :  3   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       31        9       31
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5   6
   3        3          3           5  10  14
   4        3          2          11  15
   5        3          3           9  12  17
   6        3          2           7  12
   7        3          3           8  13  14
   8        3          1          10
   9        3          2          11  13
  10        3          2          11  17
  11        3          1          16
  12        3          2          13  15
  13        3          1          16
  14        3          3          15  16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     1       9    0    0    4    0
         2     2       5    0    0    0    6
         3    10       3    0    0    2    0
  3      1     4       0    0    5    0    4
         2    10       5    0    0    5    0
         3    10       7    6    0    0    3
  4      1     2       0    5    4    5    0
         2     4       4    2    0    0    1
         3     9       2    0    0    5    0
  5      1     5       7    8    0    0    6
         2     9       0    7    0    4    0
         3    10       6    7    0    2    0
  6      1     2       7    0    0    0    9
         2     2       5    0    0    5    0
         3    10       5    0    0    0    9
  7      1     1       0    9    6    0    5
         2     4       2    0    5    0    2
         3     4       0    6    0    0    5
  8      1     1       0    6    3    0    6
         2     2       6    0    0    4    0
         3     8       6    3    3    0    5
  9      1     6       7    5    7    4    0
         2     7       7    0    7    4    0
         3     8       0    5    0    2    0
 10      1     2       3    0    0    0    8
         2     5       0    8    7    7    0
         3     8       0    0    5    0    8
 11      1     1       0    0    6    0    5
         2    10       5    0    0    3    0
         3    10       0    4    0    0    4
 12      1     2       6   10    5    9    0
         2     7       3    8    5    0    6
         3     8       0    8    0    5    0
 13      1     7       2    5    0    5    0
         2     7       0    3    0    8    0
         3     7       0    0    5    0    1
 14      1     8       0    6    2    0    4
         2     9       5    0    0    0    4
         3    10       0    6    0    0    3
 15      1     2       7    0    0    0    8
         2     3       7    0    8    0    7
         3     8       6    0    0    6    0
 16      1     9       4    0    8    7    0
         2     9       5    7    2    0    6
         3    10       4    0    0    6    0
 17      1     4       0    6    3    0    4
         2     5       0    6    0    3    0
         3    10       0    6    0    1    0
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   10   12    5   74   79
************************************************************************
