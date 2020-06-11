************************************************************************
file with basedata            : c1553_.bas
initial value random generator: 151
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  123
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19        1       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           8   9  13
   3        3          1           5
   4        3          3           5   8  17
   5        3          2           6  12
   6        3          2           7  10
   7        3          1          15
   8        3          2          11  14
   9        3          1          14
  10        3          1          11
  11        3          2          15  16
  12        3          1          13
  13        3          1          14
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       7    7    5    7
         2     6       1    2    1    7
         3     6       1    2    2    6
  3      1     3       7    5    7    7
         2     5       2    4    5    6
         3     5       3    3    5    6
  4      1     2       9    8    6    7
         2     4       7    6    6    6
         3    10       4    5    6    3
  5      1     1       6    6    3    6
         2     1       6    6    2    9
         3     8       6    5    2    4
  6      1     5       5    4    9    9
         2     6       5    3    8    7
         3     8       5    2    4    7
  7      1     8       6    6   10    9
         2     9       2    3   10    5
         3     9       3    3    9    4
  8      1     1       1    2    8    9
         2     2       1    1    5    6
         3     7       1    1    1    4
  9      1     3       2    8    9    4
         2     6       1    4    9    4
         3     6       2    3    9    3
 10      1     2       8    8    8    4
         2     4       7    4    8    4
         3     4       6    6    8    2
 11      1     4       8    6    6    6
         2     8       8    6    5    6
         3    10       7    2    1    6
 12      1     2       4    5    5    7
         2     6       3    5    4    6
         3     9       2    3    4    4
 13      1     2       4    5    9   10
         2     6       4    4    8    7
         3    10       3    3    8    7
 14      1     2       5    8    8    4
         2     5       3    6    5    3
         3     6       3    2    3    2
 15      1     2      10    7    4    9
         2     2      10    8    4    8
         3     7       9    6    4    6
 16      1     2       6    5   10    4
         2     6       5    3    9    3
         3    10       2    3    9    2
 17      1     2       7    8    8    8
         2     2       7    7    7    9
         3     8       7    5    5    7
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   13   10  106  104
************************************************************************
