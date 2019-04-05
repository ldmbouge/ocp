************************************************************************
file with basedata            : md209_.bas
initial value random generator: 1661985787
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  129
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20        1       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   9  10
   3        3          2           6  11
   4        3          1           5
   5        3          3          11  13  14
   6        3          3          10  13  16
   7        3          2           8  14
   8        3          3          11  13  16
   9        3          3          14  16  17
  10        3          2          12  17
  11        3          1          12
  12        3          1          15
  13        3          2          15  17
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       0    9    0    3
         2     7       0    9    8    0
         3     8       7    0    8    0
  3      1     4       6    0    7    0
         2     8       3    0    6    0
         3    10       0    6    4    0
  4      1     1      10    0    9    0
         2     3       9    0    0    8
         3     7       6    0    0    7
  5      1     8       0   10    3    0
         2     9       8    0    0    8
         3     9       0    5    0   10
  6      1     2       8    0    0   10
         2     5       0    8    0    4
         3    10       0    8    5    0
  7      1     2       6    0    0    8
         2     5       4    0    0    4
         3    10       2    0    0    3
  8      1     2       3    0    0    7
         2     3       3    0    7    0
         3     9       2    0    0    5
  9      1     2       0    8    0    2
         2     7       9    0    0    2
         3     8       0    6    0    2
 10      1     2       0    2   10    0
         2     8       2    0    0    5
         3     8       0    2    9    0
 11      1     3       0    2    7    0
         2     3       0    7    0    8
         3     4       6    0    6    0
 12      1     4       7    0    0    6
         2     5       6    0    6    0
         3     8       5    0    3    0
 13      1     3       0    8    7    0
         2     4       5    0    0    7
         3     5       0    6    0    1
 14      1     6       4    0    0    6
         2     7       3    0    0    2
         3     9       0    2    4    0
 15      1     3       9    0    3    0
         2     6       8    0    0    8
         3     7       8    0    0    7
 16      1     1       0    8    0    6
         2     6       5    0    2    0
         3     8       0    5    0    4
 17      1     8       4    0    0    7
         2     9       0    8    0    2
         3     9       2    0    9    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   12    6   66   77
************************************************************************
