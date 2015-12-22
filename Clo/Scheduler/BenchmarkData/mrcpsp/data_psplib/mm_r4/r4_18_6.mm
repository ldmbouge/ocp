************************************************************************
file with basedata            : cr418_.bas
initial value random generator: 1597260363
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  133
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       22        3       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6  10  13
   3        3          3           5   7   9
   4        3          2           5  12
   5        3          3          13  15  16
   6        3          2           9  14
   7        3          3           8  13  14
   8        3          3          10  11  16
   9        3          1          11
  10        3          1          17
  11        3          1          12
  12        3          2          15  17
  13        3          1          17
  14        3          2          15  16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     1       0    7    2    0    0    4
         2     3      10    0    0    0    0    4
         3     8      10    0    2    0    8    0
  3      1     4       0    7    3    0    0    3
         2     9       0    0    3    9    3    0
         3    10       3    0    0    0    0    1
  4      1     1       0    0    8    3    5    0
         2     8       0    8    0    0    0    4
         3     9       0    0    8    3    2    0
  5      1     2      10    9    9    0    5    0
         2     6       8    0    0    0    4    0
         3     9       0    6    0    0    0    9
  6      1     4       0    8    5    0    4    0
         2     6       0    7    1    0    0    2
         3     7       0    6    0    4    3    0
  7      1     1       0   10    0    0    2    0
         2     5       9    9    0    2    0    6
         3     8       0    9    7    2    0    4
  8      1     4       0    0    9    6    5    0
         2     6       0    6    0    6    0    9
         3    10       6    0    0    2    0    2
  9      1     2       2    8    0    6    9    0
         2     4       2    3    0    4    0    2
         3     6       2    3    0    0    7    0
 10      1     1       0    6    7    8    0    6
         2     9       0    5    0    5    0    5
         3     9       9    0    6    0    0    5
 11      1     3       0    5    6    5    2    0
         2     5       0    0    5    5    0    6
         3     8       2    5    0    0    0    6
 12      1     3       4    8    0    0    0    9
         2     4       0    0    8    5    4    0
         3     6       1    0    7    0    0    6
 13      1     3       5    0    7    0    0    3
         2     4       0    4    0    4    3    0
         3     6       0    3    5    0    0    2
 14      1     2       0    0    3    5    6    0
         2     4       0    8    3    4    0    6
         3     8       0    0    2    2    5    0
 15      1     1       0    0    6    8    7    0
         2     7       5    0    2    6    0    7
         3     9       0    3    0    0    5    0
 16      1     2       0    0    3    0    0    2
         2     5       0    3    0    8    0    2
         3    10       0    0    0    5    0    2
 17      1     7       5    7    0    0    0    6
         2     7       0    6    3    0    0    7
         3    10       4    0    0    4    0    5
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   12   20   12   12   47   67
************************************************************************
