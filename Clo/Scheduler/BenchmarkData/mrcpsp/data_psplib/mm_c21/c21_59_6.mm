************************************************************************
file with basedata            : c2159_.bas
initial value random generator: 388867831
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
    1     16      0       26       11       26
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   7  12
   3        3          3           6   8  10
   4        3          3           7   9  12
   5        3          3          10  11  13
   6        3          3           7   9  12
   7        3          3          11  14  17
   8        3          2           9  13
   9        3          3          11  14  17
  10        3          2          15  16
  11        3          2          15  16
  12        3          2          13  17
  13        3          2          14  16
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
  2      1     1       3    0    4    4
         2    10       0    8    4    3
         3    10       0    8    3    4
  3      1     7       3    0    8    7
         2     8       0    7    8    6
         3    10       0    7    6    6
  4      1     3       0    8    2    7
         2     3       0    6    2    9
         3    10       6    0    2    2
  5      1     1       9    0   10    9
         2     4       0    1    5    9
         3    10       8    0    4    9
  6      1     4       0    7    8    4
         2     6       5    0    8    4
         3     9       0    7    6    3
  7      1     6       0    5    4   10
         2     6       7    0    3    9
         3     6       0    7    4    7
  8      1     4       5    0    3    6
         2     5       2    0    3    5
         3     5       0   10    3    6
  9      1     1       8    0   10    6
         2     6       6    0    7    6
         3     8       0    5    7    3
 10      1     5       2    0    5    8
         2     7       0    2    5    3
         3     7       1    0    4    1
 11      1     1       0    6   10   10
         2     6       6    0    8    9
         3     7       6    0    7    8
 12      1     2       8    0    2    9
         2     3       0    8    2    6
         3     8       0    5    2    1
 13      1     3       0    7    9    3
         2     3       0    3    9    4
         3     8       7    0    8    1
 14      1     2       5    0    6   10
         2     5       0    8    5    6
         3     9       0    2    2    6
 15      1     7       0   10    9    4
         2     8       0    7    8    4
         3     9       4    0    8    4
 16      1     1       6    0    7   10
         2     1       0    5    9    9
         3     9       0    4    5    4
 17      1     1       3    0    2    6
         2     2       0    6    2    3
         3    10       0    5    2    3
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   17   20  101  116
************************************************************************
