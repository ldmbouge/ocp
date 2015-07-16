************************************************************************
file with basedata            : c2138_.bas
initial value random generator: 2135820859
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  135
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       25        5       25
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           9  11  14
   3        3          3           5   6  14
   4        3          3           8   9  14
   5        3          3           8   9  11
   6        3          3           7   8  12
   7        3          3          10  11  13
   8        3          3          10  13  15
   9        3          2          10  12
  10        3          2          16  17
  11        3          2          15  16
  12        3          2          13  17
  13        3          1          16
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       6    7    5    6
         2     8       5    7    4    3
         3    10       2    6    3    1
  3      1     4       8    6    6    3
         2     9       8    3    3    2
         3    10       7    2    1    2
  4      1     1       3    9    9    7
         2     7       2    6    7    6
         3    10       2    1    4    2
  5      1     2       6    2    6    7
         2     5       5    2    5    7
         3     6       1    1    4    7
  6      1     4       9    4    9    9
         2     5       5    4    8    5
         3    10       3    4    5    2
  7      1     7       4    6    7    9
         2     8       3    6    7    9
         3     8       4    6    6    9
  8      1     4       9    9    4    8
         2     5       7    8    4    6
         3     9       6    8    4    2
  9      1     6       9    8    7    6
         2     9       5    8    3    2
         3     9       5    7    4    3
 10      1     4       8    7    7    6
         2     6       7    6    7    6
         3     9       4    5    7    5
 11      1     7       5    7    6    9
         2    10       3    7    5    8
         3    10       2    7    5    9
 12      1     3       9   10    8    9
         2     4       9   10    8    6
         3     5       8   10    8    1
 13      1     2       2    3    7    8
         2     8       2    2    7    5
         3     9       1    2    7    4
 14      1     1       4    8   10    5
         2     9       3    8    7    4
         3    10       3    8    2    4
 15      1     1       5    3    5    5
         2     5       4    3    3    5
         3     8       3    3    2    4
 16      1     3       3    6    7    1
         2     5       3    3    6    1
         3     7       2    3    5    1
 17      1     2       9    5    8    7
         2     5       6    4    6    5
         3     5       7    3    8    3
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   15   17   82   69
************************************************************************
