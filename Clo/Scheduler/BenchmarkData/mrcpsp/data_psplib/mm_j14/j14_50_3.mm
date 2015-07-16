************************************************************************
file with basedata            : md178_.bas
initial value random generator: 1592689103
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  16
horizon                       :  105
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     14      0       16       11       16
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1           9
   3        3          3           5   6  12
   4        3          1           7
   5        3          3           9  10  15
   6        3          3           9  10  15
   7        3          3           8  10  12
   8        3          2          11  15
   9        3          2          11  14
  10        3          2          11  14
  11        3          1          13
  12        3          2          13  14
  13        3          1          16
  14        3          1          16
  15        3          1          16
  16        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       0    4    9    7
         2     3       5    0    7    6
         3    10       0    2    6    3
  3      1     8       6    0    4    8
         2     8       0    7    5    4
         3     8       0    8    4    4
  4      1     3       4    0    5    7
         2     6       3    0    5    7
         3     8       0    2    5    6
  5      1     2       0    3    7    4
         2     3       0    3    6    3
         3     4       0    3    3    2
  6      1     2      10    0    8    5
         2     2       0    5    9    5
         3     9      10    0    8    4
  7      1     5      10    0    6    3
         2     6      10    0    3    2
         3     9       9    0    3    1
  8      1     1       0    2    4   10
         2     2       0    1    3   10
         3     8       0    1    2    9
  9      1     2       0    4    6    3
         2     3       0    2    4    3
         3     4       7    0    4    2
 10      1     1       0    3    5    6
         2     2       5    0    5    5
         3     8       5    0    3    1
 11      1     1       0    8   10    7
         2     5       0    6    6    6
         3     8      10    0    3    3
 12      1     1       0    8    3    3
         2     3       8    0    2    3
         3     4       6    0    2    2
 13      1     3       9    0   10    5
         2     5       7    0    8    5
         3     9       0    9    6    4
 14      1     4       0    5    6    9
         2     7       7    0    4    8
         3     9       0    5    4    8
 15      1     2       0    4    4    3
         2     6       0    4    3    3
         3     7       0    3    1    2
 16      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   15   11   80   73
************************************************************************
