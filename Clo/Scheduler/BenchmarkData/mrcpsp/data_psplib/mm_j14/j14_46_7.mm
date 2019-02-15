************************************************************************
file with basedata            : md174_.bas
initial value random generator: 342933247
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  16
horizon                       :  102
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     14      0       15        8       15
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5   7
   3        3          3           7   8  12
   4        3          2           5   6
   5        3          3          10  12  14
   6        3          1           9
   7        3          3          10  13  14
   8        3          2           9  10
   9        3          3          11  13  14
  10        3          1          15
  11        3          1          15
  12        3          2          13  15
  13        3          1          16
  14        3          1          16
  15        3          1          16
  16        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       7    8    6    8
         2     7       7    8    4    4
         3     8       7    7    3    1
  3      1     1       7    9    8    9
         2     2       7    7    5    9
         3     3       7    7    4    9
  4      1     3       6    6    1    9
         2     6       4    3    1    7
         3    10       3    2    1    5
  5      1     3       9   10    8    9
         2     6       6    5    8    8
         3     8       3    4    8    6
  6      1     3       3    6    5   10
         2     3       3    7    5    8
         3     7       3    5    2    4
  7      1     1       9    7    6    7
         2     2       9    7    5    7
         3     4       8    4    5    5
  8      1     4       7    6    8    9
         2     7       7    6    7    4
         3     9       4    3    6    3
  9      1     1      10    2    9    4
         2     3       5    1    9    2
         3    10       5    1    8    1
 10      1     2       8    6    7    6
         2     7       7    5    4    4
         3    10       6    5    2    4
 11      1     4       9   10   10    8
         2     7       6    7   10    8
         3     9       5    6    9    6
 12      1     3       8    5    7   10
         2     4       4    3    5    9
         3     4       2    5    6   10
 13      1     4       6    7    8    8
         2     4       6    7    6    9
         3     6       4    7    5    6
 14      1     1       9    6    7    6
         2     9       6    6    7    2
         3     9       8    5    6    5
 15      1     4       7    7   10    9
         2     5       3    6   10    9
         3     5       3    7   10    8
 16      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   21   17   87   91
************************************************************************
