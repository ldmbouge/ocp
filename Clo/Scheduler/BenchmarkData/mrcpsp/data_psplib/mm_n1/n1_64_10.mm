************************************************************************
file with basedata            : cn164_.bas
initial value random generator: 1060004559
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  129
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       27        5       27
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           9  10
   3        3          1           5
   4        3          3           5   6   7
   5        3          3           9  12  13
   6        3          2           8  11
   7        3          3           8  11  13
   8        3          3           9  10  12
   9        3          2          15  16
  10        3          2          14  15
  11        3          1          12
  12        3          2          14  15
  13        3          1          14
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     1       5    5    8
         2     9       4    2    8
         3    10       4    1    8
  3      1     3       6    8    8
         2     5       5    6    7
         3     8       3    1    6
  4      1     5       9    7    7
         2     9       8    5    3
         3     9       9    3    2
  5      1     1       8    3    8
         2     3       6    2    8
         3     6       3    2    7
  6      1     3      10    8    7
         2     6       9    7    7
         3     7       9    5    6
  7      1     3       5    7    5
         2     9       4    1    4
         3     9       4    3    3
  8      1     9       8    4    7
         2    10       7    2    6
         3    10       8    1    7
  9      1     2       8   10    9
         2     2       9    8    8
         3     6       8    7    5
 10      1     6       7    9   10
         2     9       7    7    9
         3    10       6    7    9
 11      1     4       9    9    6
         2     6       7    9    4
         3     7       6    9    3
 12      1     1       9   10    8
         2     6       9    9    7
         3     7       8    6    7
 13      1     1       3    7    6
         2     8       2    6    5
         3     9       2    6    3
 14      1     1       3   10    9
         2     2       2    9    6
         3     6       2    7    4
 15      1     2       6    9    7
         2     4       5    7    7
         3     6       5    6    4
 16      1     2       4    8    9
         2     2       5    9    8
         3     9       3    7    6
 17      1     3       1    8   10
         2     9       1    7   10
         3    10       1    7    9
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   25   29  124
************************************************************************
