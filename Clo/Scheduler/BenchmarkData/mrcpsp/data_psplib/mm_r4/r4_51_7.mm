************************************************************************
file with basedata            : cr451_.bas
initial value random generator: 1244926313
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  125
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21       13       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1           5
   3        3          1          10
   4        3          3           8   9  10
   5        3          3           6   7   9
   6        3          2           8  10
   7        3          1          13
   8        3          2          11  12
   9        3          3          14  16  17
  10        3          2          11  12
  11        3          3          13  14  16
  12        3          3          13  14  16
  13        3          2          15  17
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     8       2    3    0    6    4    8
         2    10       0    0    5    0    4    8
         3    10       0    0    0    6    4    7
  3      1     1       0    7    7    2    6    4
         2     6       0    0    5    1    6    3
         3    10       0    6    4    0    6    2
  4      1     2       9    0    4    9    8    6
         2     6       7    0    0    9    6    6
         3     7       7    2    0    9    3    5
  5      1     4       3    0    0    7    2   10
         2     7       2    2    0    0    2   10
         3    10       2    0    3    0    2   10
  6      1     2       7    9    7    9    6    6
         2     3       6    0    0    9    4    4
         3     9       4    0    6    0    3    3
  7      1     5       0    0    7    7   10    8
         2     6       5    0    0    0    7    6
         3     8       0    0    0    4    6    4
  8      1     1       0    0    6    0    5    9
         2     4       0    0    6    0    3    8
         3     8       7    5    5    0    3    8
  9      1     4       5    0    0    2    6    5
         2     8       0    0    8    0    3    5
         3    10       0    0    6    2    1    5
 10      1     1       0    2    0    7    6    7
         2     2       0    0    0    6    6    5
         3     4       0    2    9    0    5    5
 11      1     1       0    2    0    0    5    8
         2     2       0    0    1    7    5    8
         3     3       2    2    0    6    4    8
 12      1     2       8    2    0   10    9   10
         2     5       0    0    0   10    6    9
         3     7       0    1    4   10    6    8
 13      1     1       0    0    6    9   10    9
         2     2       0    0    0    6    9    9
         3     9       0    0    4    0    8    8
 14      1     2       0    0    7    6   10    7
         2     2       5    2    0    7   10    7
         3     9       0    0    0    6    4    5
 15      1     2       9    8    3    0    8    7
         2     8       0    8    0    4    7    4
         3    10       9    7    0    0    6    3
 16      1     2       0    3    0    7   10    6
         2     2       6    3    5    0   10    6
         3     8       3    2    0    0    9    5
 17      1     3       6    0    0    0    7    4
         2     3       0    0    6    3    7    4
         3     3       6    3    6    0    6    3
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   15   11   24   22  103  108
************************************************************************
