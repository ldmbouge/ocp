************************************************************************
file with basedata            : cn113_.bas
initial value random generator: 1025468514
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  118
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23       14       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2          12  15
   3        3          2           6  10
   4        3          3           5   6  10
   5        3          1           7
   6        3          3           9  12  14
   7        3          3           8  12  14
   8        3          2           9  13
   9        3          2          11  17
  10        3          2          13  16
  11        3          2          15  16
  12        3          1          13
  13        3          1          17
  14        3          3          15  16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     1       7   10    5
         2     5       7    9    4
         3     9       2    8    0
  3      1     3       7    3    0
         2     7       6    2    9
         3     9       5    1    0
  4      1     2       9    2    5
         2     6       8    1    0
         3     6       6    2    0
  5      1     9       9    7    0
         2     9       6    8    0
         3    10       5    7    0
  6      1     6       7    9    3
         2     7       5    8    0
         3     9       1    6    0
  7      1     3       7    3    6
         2     6       6    2    0
         3    10       5    1    0
  8      1     2       8    8    0
         2     4       8    4    8
         3     5       7    3    7
  9      1     1       8    6    4
         2     2       4    4    4
         3     2       6    4    0
 10      1     8       6    9    8
         2    10       5    9    4
         3    10       4    8    5
 11      1     4       3    8    7
         2     7       3    5    2
         3     7       2    7    0
 12      1     4       5    2    9
         2     5       2    2    0
         3     7       1    2    0
 13      1     1       7    8    2
         2     2       6    7    2
         3     2       7    6    0
 14      1     3       9    7    5
         2     4       8    5    0
         3     8       7    2    0
 15      1     2       3   10    0
         2     3       2   10    7
         3    10       2    9    0
 16      1     1       7    3    8
         2     2       5    3    0
         3     5       4    2    0
 17      1     1       3    2    9
         2     6       2    1    7
         3     9       2    1    5
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   11   13   52
************************************************************************
