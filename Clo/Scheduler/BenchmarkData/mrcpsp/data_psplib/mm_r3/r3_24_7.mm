************************************************************************
file with basedata            : cr324_.bas
initial value random generator: 1009115741
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  127
RESOURCES
  - renewable                 :  3   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21        9       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   9
   3        3          2           7  15
   4        3          3           8   9  10
   5        3          3           7  11  13
   6        3          2           8  16
   7        3          1          16
   8        3          2          14  17
   9        3          2          11  13
  10        3          2          11  13
  11        3          2          12  17
  12        3          2          14  16
  13        3          2          15  17
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
  2      1     3       8    9    9    0    1
         2     9       7    8    6    6    0
         3    10       6    8    6    4    0
  3      1     2       8    6    3    0    5
         2    10       7    5    2    0    4
         3    10       8    3    2    0    3
  4      1     1       8    4    4    4    0
         2     2       8    4    3    0    4
         3     9       8    3    3    4    0
  5      1     1       9    9    3    8    0
         2     5       9    9    2    8    0
         3     6       8    8    2    7    0
  6      1     8       2    5    7    0    3
         2     9       2    4    5    4    0
         3     9       2    3    5    8    0
  7      1     2       2    9    7    4    0
         2     3       2    9    6    0    3
         3     3       1    9    6    0    4
  8      1     2       9    4    8    3    0
         2     7       9    2    7    3    0
         3    10       7    2    5    0    6
  9      1     1       9    7    9    6    0
         2     3       8    6    7    0    5
         3     4       8    6    7    6    0
 10      1     1       8    3    5    0    6
         2     2       8    3    3    4    0
         3     5       5    2    3    0    5
 11      1     4       5    5    2    0    8
         2     7       2    1    2    0    7
         3     7       3    4    1    5    0
 12      1     2       9    7    8    9    0
         2     7       6    6    8    7    0
         3    10       6    6    7    0    7
 13      1     1       4    6    4    0    8
         2     9       2    6    3    0    7
         3     9       3    6    2   10    0
 14      1     5       2    8    5    0    6
         2     8       2    7    4    0    3
         3    10       1    5    3    7    0
 15      1     3       8    2    9    0    3
         2     7       6    2    9    7    0
         3     8       5    1    7    7    0
 16      1     6       4    9    7    0    3
         2     9       2    8    6    3    0
         3    10       1    7    6    0    1
 17      1     4       6    1    6    0    6
         2     5       6    1    6    0    4
         3     7       6    1    6    0    2
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   24   25   20   65   58
************************************************************************
