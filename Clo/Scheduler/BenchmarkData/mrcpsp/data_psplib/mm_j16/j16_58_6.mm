************************************************************************
file with basedata            : md250_.bas
initial value random generator: 449106580
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  131
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       24        1       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   8  15
   3        3          3           7  14  15
   4        3          2           5   6
   5        3          3           8  10  14
   6        3          3          11  14  16
   7        3          2           8  10
   8        3          2           9  13
   9        3          2          11  16
  10        3          2          11  12
  11        3          1          17
  12        3          2          13  16
  13        3          1          17
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
  2      1     3       0    8    3    3
         2     7       0    5    2    2
         3     9       0    3    2    1
  3      1     4       1    0    7    7
         2     5       0    3    7    6
         3     7       0    3    5    3
  4      1     1       5    0    7    7
         2     3       0    4    5    6
         3     6       4    0    4    6
  5      1     1       0    8    5    9
         2     2       8    0    5    9
         3     7       8    0    3    8
  6      1     1       0    5    2    8
         2     3       8    0    2    7
         3     4       7    0    1    7
  7      1     5       0    7    7    4
         2     8       0    7    6    3
         3     8       6    0    7    3
  8      1     4       0    9    8    8
         2     5       0    8    5    4
         3     9       0    6    2    3
  9      1     5       2    0    9   10
         2     7       2    0    4    4
         3     8       2    0    4    1
 10      1     1       0   10    6    6
         2     8       0    7    5    5
         3    10       0    6    5    5
 11      1     4      10    0    4    7
         2     6       0    7    3    6
         3    10       0    4    1    6
 12      1     6       0    6    7    9
         2     9       6    0    5    9
         3     9       0    5    5    9
 13      1     2       6    0   10    9
         2     8       0    5    9    7
         3     9       6    0    8    4
 14      1     4       0    4    6    5
         2     9       5    0    6    5
         3    10       0    3    6    4
 15      1     1       2    0    8    9
         2     4       0    3    8    9
         3     8       1    0    7    7
 16      1     2       0    3    4    8
         2     6       0    1    4    7
         3     7       8    0    4    6
 17      1     2       7    0    4    9
         2    10       6    0    2    8
         3    10       0    2    1    8
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   13   13   97  118
************************************************************************
