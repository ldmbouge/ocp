************************************************************************
file with basedata            : c1519_.bas
initial value random generator: 999559978
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  126
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       24        3       24
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   7
   3        3          1          14
   4        3          2          11  15
   5        3          1           8
   6        3          2          12  17
   7        3          2          10  13
   8        3          2           9  13
   9        3          2          12  15
  10        3          1          12
  11        3          2          16  17
  12        3          1          14
  13        3          1          17
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
  2      1     5       0    2    5    0
         2     5       0    2    0    3
         3     6       0    2    4    0
  3      1     1       0    2    9    0
         2     1       0    2    0    8
         3     5       0    1    0    4
  4      1     6       6    0    8    0
         2     6       0    9    0    8
         3     9       0    8   10    0
  5      1     3       7    0    2    0
         2     5       0    4    2    0
         3     5       2    0    0    6
  6      1     3       0    5    0    9
         2     4       8    0    0    6
         3     5       7    0    1    0
  7      1     2       0    9    0    7
         2     6       0    3    0    6
         3    10       4    0    2    0
  8      1     3       8    0    0    7
         2     6       0    6    0    4
         3     8       8    0    1    0
  9      1     7       0    8    0    4
         2     9       0    4    5    0
         3    10       5    0    0    4
 10      1     1       7    0    8    0
         2     5       0    6    0    3
         3     7       0    3    0    3
 11      1     3       0    7    6    0
         2     6       0    5    4    0
         3     9       0    4    0   10
 12      1     1       4    0    2    0
         2     4       0    3    0    3
         3    10       0    1    2    0
 13      1     3       0    5    4    0
         2     6       5    0    2    0
         3     7       0    3    0    6
 14      1     1       9    0    0   10
         2     6       9    0    7    0
         3     7       0    5    0    7
 15      1     1       5    0    0    5
         2     6       0    4    0    4
         3    10       4    0    2    0
 16      1     4       0    7    0    5
         2     7       6    0    2    0
         3     8       4    0    0    4
 17      1     5       7    0    8    0
         2     9       4    0    6    0
         3    10       0    7    0    8
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   19   21   56   77
************************************************************************
