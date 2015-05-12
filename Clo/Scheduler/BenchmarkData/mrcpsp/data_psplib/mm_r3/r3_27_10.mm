************************************************************************
file with basedata            : cr327_.bas
initial value random generator: 369975104
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  118
RESOURCES
  - renewable                 :  3   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20       10       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   7  10
   3        3          3           6   7   9
   4        3          3           5   8  13
   5        3          2          11  12
   6        3          2          13  16
   7        3          2          11  12
   8        3          2          11  15
   9        3          2          14  17
  10        3          2          13  16
  11        3          1          16
  12        3          2          14  17
  13        3          2          14  17
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     3       6    8    5    8    0
         2     4       0    7    4    0    4
         3     4       5    0    5    6    0
  3      1     2      10    4    0    6    0
         2     3       0    0    3    4    0
         3     4       9    0    2    0    1
  4      1     2       8    3    5    0    7
         2     2       8    4    0    3    0
         3     3       0    3    0    0    6
  5      1     7      10    5    4    0    5
         2     8       0    3    0    0    4
         3     9       2    0    0   10    0
  6      1     3       0    0    6    0    3
         2     4       0    0    1    7    0
         3    10       7    0    0    5    0
  7      1     1       0    7    0   10    0
         2     2       4    4    0    0    8
         3     4       3    3    0    8    0
  8      1     1       6    0    0    0    9
         2     4       4    0    0    2    0
         3     7       3    0    4    0    7
  9      1     3       0    9    0    0    4
         2    10       6    0    0    0    4
         3    10       0    0    8    5    0
 10      1     4       0    9    0    4    0
         2     4       0   10    0    0    6
         3     7       2    0    3    0    4
 11      1     2       0    4    5    5    0
         2     4       0    3    0    0    8
         3     5       8    3    0    3    0
 12      1     2       0    0    5    9    0
         2     4       0    0    2    0    7
         3    10       5    8    0    3    0
 13      1     5       0    3    0    0    3
         2     9       4    3    0    2    0
         3     9       5    2    0    4    0
 14      1     4       4    6    0    5    0
         2     8       0    4    0    2    0
         3    10       0    4    4    0    6
 15      1     4       4    9    0    6    0
         2     5       0    9    0    0    7
         3    10       1    0    0    3    0
 16      1     1       0    4    9    0    3
         2     5       0    3    3    4    0
         3     6       7    0    0    4    0
 17      1     3       6    0    0    0    6
         2     8       0    0    6    0    6
         3    10       0    8    0    0    5
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   23   24   20   88   87
************************************************************************
