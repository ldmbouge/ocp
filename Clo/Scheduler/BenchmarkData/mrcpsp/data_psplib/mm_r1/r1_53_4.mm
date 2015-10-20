************************************************************************
file with basedata            : cr153_.bas
initial value random generator: 1159612429
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
    1     16      0       18        0       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          10  12  16
   3        3          3           5   8  10
   4        3          3           6  11  12
   5        3          3          11  15  17
   6        3          2           7  13
   7        3          2          10  16
   8        3          3           9  12  17
   9        3          2          11  13
  10        3          2          14  15
  11        3          1          16
  12        3          1          13
  13        3          1          15
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     2       8    8    9
         2     3       6    8    7
         3     5       6    5    5
  3      1     1       6    4    8
         2     5       6    3    8
         3     9       5    3    8
  4      1     5       5    8    5
         2     5       6    8    4
         3     9       4    8    2
  5      1     2       8    5    9
         2     5       6    3    9
         3    10       4    2    8
  6      1     3       2    6    8
         2     7       1    6    3
         3     7       2    5    4
  7      1     3       7    4   10
         2     5       6    2    8
         3     7       5    1    7
  8      1     1       6    1    7
         2     2       6    1    6
         3     5       6    1    4
  9      1     3       5    8    9
         2     4       4    4    4
         3    10       2    2    3
 10      1     1       5    9    4
         2     2       3    6    3
         3     4       2    5    2
 11      1     1       8    9    4
         2     3       8    6    3
         3     8       8    3    3
 12      1     2       4    8    5
         2     4       3    6    4
         3    10       2    5    2
 13      1     5       7    9    6
         2     6       7    8    5
         3     9       3    8    2
 14      1     2       8    7    6
         2     3       7    5    4
         3     9       6    5    3
 15      1     5       8   10    4
         2     9       7    7    3
         3    10       6    5    3
 16      1     1       9    8    4
         2     6       5    5    4
         3     9       5    4    3
 17      1     1      10    6    8
         2     3       7    4    6
         3     7       7    4    3
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  N 1  N 2
   13   99   95
************************************************************************
