************************************************************************
file with basedata            : cr454_.bas
initial value random generator: 127345528
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  140
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       25       11       25
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   9  10
   3        3          2          11  13
   4        3          3           6   7  10
   5        3          1          17
   6        3          2           8   9
   7        3          3           8   9  13
   8        3          1          17
   9        3          2          11  12
  10        3          3          12  13  17
  11        3          2          14  16
  12        3          2          15  16
  13        3          2          14  16
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     4       7    8    5   10    8    6
         2     5       4    7    5    8    7    4
         3     9       4    5    4    6    7    4
  3      1     2       7    2    8    9   10    5
         2     7       7    2    8    8    8    4
         3     8       5    1    7    5    5    1
  4      1     6       8    5    8    9    9    6
         2     7       8    4    8    9    9    4
         3     9       7    4    8    8    6    2
  5      1     1      10    7    4    2    7    4
         2     7       7    7    4    2    6    4
         3     9       7    7    2    2    5    2
  6      1     5       7    7    8    8    7    7
         2     5       7    8    8    7    6    8
         3     7       7    6    4    3    6    6
  7      1     5       7    5    8    9    8    9
         2     6       5    5    6    7    6    7
         3     8       4    5    5    5    3    4
  8      1     1       9    7    8    9    8    7
         2     6       5    7    8    7    6    7
         3     9       3    7    8    6    2    7
  9      1     5       8    6    8    5    3    9
         2     8       6    5    8    4    3    7
         3     9       5    2    8    4    2    6
 10      1     4       8   10    9   10    3    7
         2    10       8    8    9    8    2    7
         3    10       7    9    7    8    1    7
 11      1     2       8   10    8   10    5    3
         2     6       8   10    6    5    5    3
         3    10       8    9    4    5    5    2
 12      1     5       6    5    4    3    3    8
         2     8       5    3    4    2    2    7
         3     9       5    3    2    1    2    7
 13      1     8       7    4    1    3    7    1
         2     9       6    3    1    3    5    1
         3     9       6    2    1    2    6    1
 14      1     1       7    6    9    8    7    6
         2     4       7    6    7    5    7    6
         3     8       6    5    7    5    7    4
 15      1     3       7    8    5    5    6   10
         2     5       6    7    5    5    5    6
         3     8       5    6    4    3    3    6
 16      1     4       3    8    4    6    5    6
         2     8       2    8    3    4    1    5
         3     8       2    8    4    4    2    4
 17      1     5       8    9    9    9    4    4
         2     9       6    8    8    7    4    4
         3    10       5    8    7    4    3    1
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   19   19   17   18   91   90
************************************************************************
