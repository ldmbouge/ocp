************************************************************************
file with basedata            : md219_.bas
initial value random generator: 1710798520
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  139
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21       14       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7  14  17
   3        3          3           6  10  13
   4        3          3           5   6   9
   5        3          3          10  13  17
   6        3          2          12  16
   7        3          2           8  16
   8        3          3          11  12  13
   9        3          3          10  12  14
  10        3          1          11
  11        3          1          15
  12        3          1          15
  13        3          1          15
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
  2      1     1       0    8    0    9
         2     8       0    3    2    0
         3     9       0    2    0    8
  3      1     4       0    3    0    8
         2     6       0    3    0    3
         3     6       5    0    2    0
  4      1     6       4    0    0    9
         2     9       1    0    5    0
         3    10       0    3    0    3
  5      1     1       7    0    0    5
         2     3       6    0    0    5
         3     9       1    0    8    0
  6      1     2       0    4    8    0
         2     9       0    4    0    2
         3    10       0    1    2    0
  7      1     1       0   10    7    0
         2     3       0    7    6    0
         3    10       0    3    1    0
  8      1     2       5    0    0    6
         2     3       0    2   10    0
         3     9       3    0   10    0
  9      1     3       0    4    8    0
         2     7       2    0    0    8
         3     9       1    0    0    7
 10      1     2       0    8   10    0
         2     5      10    0    7    0
         3     9       0    7    6    0
 11      1     5       0    4    0    9
         2     6       4    0    0    6
         3    10       2    0    5    0
 12      1     3       8    0    8    0
         2     6       0    2    7    0
         3     9       0    1    5    0
 13      1     3       9    0    0    8
         2     6       0    7    4    0
         3     6       6    0    0    8
 14      1     1       0    8    0    9
         2     6       4    0    0    9
         3     9       0    7    2    0
 15      1     5       9    0   10    0
         2     7       0    7    7    0
         3    10       8    0    0    9
 16      1     1       0    4    0    5
         2     6       6    0    0    3
         3     6       0    4    8    0
 17      1     2      10    0    0    3
         2     3       0    1    0    3
         3     8       6    0    0    3
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   17   20   97   90
************************************************************************
